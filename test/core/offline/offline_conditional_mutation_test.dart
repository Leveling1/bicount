import 'dart:convert';

import 'package:bicount/core/offline/offline_conditional_mutation.dart';
import 'package:bicount/core/offline/offline_conditional_acknowledgement.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  sqfliteFfiInit();

  test('acknowledgement preserves a newer local edit and rebases it', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    final first = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'tid': 'id', 'amount': 10},
    );
    final second = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'tid': 'id', 'amount': 20},
    );
    await outbox.commit(first, (_) async {});
    await outbox.commit(second, (_) async {});
    await acknowledgeConditionalMutation(
      db: db,
      operation: first,
      remoteRow: {'tid': 'id', 'amount': 10},
      journalSequence: 7,
      journalGeneration: 1,
    );
    expect((await outbox.pending('u')).single.id, second.id);
    final baseline = (await db.query('bicount_remote_baseline')).single;
    expect(
      (jsonDecode(baseline['remote_payload'] as String) as Map)['amount'],
      10,
    );
    expect(baseline['journal_sequence'], 7);
  });
  test('unknown baseline never sends a mutation', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await OfflineOutbox(db).initialize();
    final client = SupabaseClient(
      'http://localhost',
      'key',
      httpClient: MockClient(
        (_) async => throw StateError('unexpected network'),
      ),
    );
    addTearDown(client.dispose);
    final op = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'delete',
      payload: {'tid': 'id'},
    );
    expect(
      (await sendConditionalMutation(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => 'u',
      )).result,
      ConditionalMutationResult.unavailable,
    );
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({'tid': 'id'}),
    });
    expect(
      (await sendConditionalMutation(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => 'u',
      )).result,
      ConditionalMutationResult.unavailable,
    );
  });

  test('delete sends the nullable patch required by the server', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await OfflineOutbox(db).initialize();
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({'tid': 'id', 'amount': 10}),
      'journal_sequence': 2,
      'journal_generation': 1,
    });
    final client = SupabaseClient(
      'http://localhost',
      'key',
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        expect(body['p_action'], 'delete');
        expect(body.containsKey('p_patch'), isTrue);
        expect(body['p_patch'], isNull);
        return http.Response(
          '{"status":"applied","row":{"tid":"id"},"journal_sequence":3,"journal_generation":1}',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    final response = await sendConditionalMutation(
      db: db,
      client: client,
      operation: OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'delete',
        payload: {'tid': 'id'},
      ),
      currentUserId: () => 'u',
    );
    expect(response.result, ConditionalMutationResult.applied);
  });

  test('accepted update returns the confirmed server row', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await OfflineOutbox(db).initialize();
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({'tid': 'id', 'amount': 10}),
      'journal_sequence': 2,
      'journal_generation': 1,
    });
    final client = SupabaseClient(
      'http://localhost',
      'key',
      httpClient: MockClient(
        (request) async => http.Response(
          '{"status":"applied","row":{"tid":"id","amount":20},"journal_sequence":3,"journal_generation":1}',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.dispose);
    final op = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'tid': 'id', 'amount': 20},
    );
    final response = await sendConditionalMutation(
      db: db,
      client: client,
      operation: op,
      currentUserId: () => 'u',
    );
    expect(response.result, ConditionalMutationResult.applied);
    expect(response.remoteRow?['amount'], 20);
  });

  test(
    'the last observed baseline is sent and a conflict remains pending',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await db.insert('bicount_remote_baseline', {
        'user_id': 'u',
        'collection': 'transactions',
        'record_id': 'id',
        'remote_payload': jsonEncode({'tid': 'id', 'amount': 10}),
        'journal_sequence': 2,
        'journal_generation': 1,
      });
      final op = OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'upsert',
        payload: {'tid': 'id', 'amount': 15},
      );
      await outbox.commit(op, (_) async {});
      final client = SupabaseClient(
        'http://localhost',
        'key',
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            endsWith('/rpc/bicount_conditional_journal_guard'),
          );
          final body = jsonDecode(request.body) as Map;
          expect(body['p_expected']['amount'], 10);
          expect(body['p_patch']['amount'], 15);
          expect(body['p_seen_sequence'], 2);
          expect(body['p_generation'], 1);
          return http.Response(
            '{"status":"conflict"}',
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      expect(
        (await sendConditionalMutation(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
        )).result,
        ConditionalMutationResult.conflict,
      );
      expect((await outbox.pending('u')).single.id, op.id);
    },
  );

  test('an account change during a request never reports success', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await OfflineOutbox(db).initialize();
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({'tid': 'id', 'amount': 10}),
      'journal_sequence': 2,
      'journal_generation': 1,
    });
    var currentUser = 'u';
    final client = SupabaseClient(
      'http://localhost',
      'key',
      httpClient: MockClient((request) async {
        currentUser = 'another-user';
        return http.Response(
          '{"status":"applied"}',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);
    final op = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'delete',
      payload: {'tid': 'id'},
    );
    await expectLater(
      sendConditionalMutation(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => currentUser,
      ),
      throwsStateError,
    );
  });
}
