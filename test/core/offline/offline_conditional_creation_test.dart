import 'dart:convert';

import 'package:bicount/core/offline/offline_conditional_creation.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late OfflineOutbox outbox;
  late OfflineOperation operation;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    outbox = OfflineOutbox(db);
    await outbox.initialize();
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'upsert',
        isCreation: true,
        payload: {'tid': 'id', 'amount': 10},
      ),
      (_) async {},
    );
    operation = (await outbox.pending('u')).single;
  });
  tearDown(() => db.close());

  SupabaseClient clientFor(MockClient client) =>
      SupabaseClient('http://127.0.0.1:54321', 'test', httpClient: client);
  http.Response jsonResponse(
    http.Request request,
    Object value, [
    int status = 200,
  ]) => http.Response(
    jsonEncode(value),
    status,
    request: request,
    headers: {'content-type': 'application/json'},
  );

  test(
    'confirmed insert is acknowledged with a conservative watermark',
    () async {
      var inserts = 0;
      final client = clientFor(
        MockClient((request) async {
          if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
            return jsonResponse(request, {
              'enabled': true,
              'latest_sequence': 4,
              'generation': 1,
            });
          }
          inserts++;
          return jsonResponse(request, {
            'status': 'applied',
            'row': {'tid': 'id', 'amount': 10},
          });
        }),
      );
      expect(
        await deliverConditionalCreation(
          db: db,
          client: client,
          operation: operation,
          currentUserId: () => 'u',
        ),
        isTrue,
      );
      expect(inserts, 1);
      expect(await outbox.pending('u'), isEmpty);
      expect(
        (await db.query('bicount_remote_baseline')).single['journal_sequence'],
        4,
      );
      client.dispose();
    },
  );

  test('lost response recovers using the original creation receipt', () async {
    var inserts = 0;
    final client = clientFor(
      MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse(request, {
            'enabled': true,
            'latest_sequence': 4,
            'generation': 1,
          });
        }
        if (request.url.path.endsWith('/rpc/bicount_create_once')) {
          inserts++;
          if (inserts == 1) throw http.ClientException('connection lost');
          return jsonResponse(request, {'status': 'already_applied'});
        }
        return jsonResponse(request, {'tid': 'id', 'amount': 10});
      }),
    );
    Future<bool> send() => deliverConditionalCreation(
      db: db,
      client: client,
      operation: operation,
      currentUserId: () => 'u',
    );
    await expectLater(send(), throwsA(isA<http.ClientException>()));
    expect(await send(), isTrue);
    expect(inserts, 2);
    expect(await outbox.pending('u'), isEmpty);
    client.dispose();
  });

  test('a local edit during insertion remains queued', () async {
    final client = clientFor(
      MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse(request, {
            'enabled': true,
            'latest_sequence': 4,
            'generation': 1,
          });
        }
        await outbox.commit(
          OfflineOperation(
            userId: 'u',
            collection: 'transactions',
            recordId: 'id',
            action: 'upsert',
            payload: {'tid': 'id', 'amount': 20},
          ),
          (_) async {},
        );
        return jsonResponse(request, {
          'status': 'applied',
          'row': {'tid': 'id', 'amount': 10},
        });
      }),
    );
    expect(
      await deliverConditionalCreation(
        db: db,
        client: client,
        operation: operation,
        currentUserId: () => 'u',
      ),
      isTrue,
    );
    final pending = (await outbox.pending('u')).single;
    expect(pending.payload['amount'], 20);
    expect(pending.isCreation, isFalse);
    expect(
      (await db.query('bicount_remote_baseline')).single['journal_sequence'],
      4,
    );
    client.dispose();
  });

  test('disabled journal prevents sending or reserving a creation', () async {
    var inserts = 0;
    final client = clientFor(
      MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse(request, {'enabled': false});
        }
        inserts++;
        return jsonResponse(request, {'tid': 'id', 'amount': 10}, 201);
      }),
    );
    expect(
      await deliverConditionalCreation(
        db: db,
        client: client,
        operation: operation,
        currentUserId: () => 'u',
      ),
      isFalse,
    );
    expect(inserts, 0);
    expect(await db.query('bicount_creation_attempts'), isEmpty);
    expect((await outbox.pending('u')).single.id, operation.id);
    client.dispose();
  });

  test(
    'receipt retry preserves the queue if server contents changed',
    () async {
      var attempts = 0;
      final client = clientFor(
        MockClient((request) async {
          if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
            return jsonResponse(request, {
              'enabled': true,
              'latest_sequence': 4,
              'generation': 1,
            });
          }
          if (request.url.path.endsWith('/rpc/bicount_create_once')) {
            if (++attempts == 1) throw http.ClientException('response lost');
            return jsonResponse(request, {'status': 'already_applied'});
          }
          return jsonResponse(request, {'tid': 'id', 'amount': 30});
        }),
      );
      Future<bool> send() => deliverConditionalCreation(
        db: db,
        client: client,
        operation: operation,
        currentUserId: () => 'u',
      );
      await expectLater(send(), throwsA(isA<http.ClientException>()));
      expect(await send(), isFalse);
      expect((await outbox.pending('u')).single.id, operation.id);
      expect(await db.query('bicount_remote_baseline'), isEmpty);
      client.dispose();
    },
  );

  test(
    'receipt retry uses the first payload after a later offline edit',
    () async {
      var attempts = 0;
      final client = clientFor(
        MockClient((request) async {
          if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
            return jsonResponse(request, {
              'enabled': true,
              'latest_sequence': 4,
              'generation': 1,
            });
          }
          if (request.url.path.endsWith('/rpc/bicount_create_once')) {
            final body = jsonDecode(request.body) as Map;
            expect((body['p_payload'] as Map)['amount'], 10);
            if (++attempts == 1) throw http.ClientException('response lost');
            return jsonResponse(request, {'status': 'already_applied'});
          }
          return jsonResponse(request, {'tid': 'id', 'amount': 10});
        }),
      );
      await expectLater(
        deliverConditionalCreation(
          db: db,
          client: client,
          operation: operation,
          currentUserId: () => 'u',
        ),
        throwsA(isA<http.ClientException>()),
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'id',
          action: 'upsert',
          payload: {'tid': 'id', 'amount': 20},
        ),
        (_) async {},
      );
      final newer = (await outbox.pending('u')).single;
      expect(
        await deliverConditionalCreation(
          db: db,
          client: client,
          operation: newer,
          currentUserId: () => 'u',
        ),
        isTrue,
      );
      final pending = (await outbox.pending('u')).single;
      expect(pending.payload['amount'], 20);
      expect(pending.isCreation, isFalse);
      client.dispose();
    },
  );
}
