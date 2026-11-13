import 'dart:io';

import 'package:bicount/core/offline/offline_conditional_creation.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class _LoseFirstCreationResponse extends http.BaseClient {
  final http.Client _inner = http.Client();
  bool lost = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (!lost && request.url.path.endsWith('/rpc/bicount_create_once')) {
      lost = true;
      await response.stream.drain();
      throw http.ClientException('Simulated lost response');
    }
    return response;
  }

  @override
  void close() => _inner.close();
}

void main() {
  sqfliteFfiInit();
  final key = Platform.environment['BICOUNT_PREPROD_TEST_ANON'];
  final token = Platform.environment['BICOUNT_PREPROD_TEST_TOKEN'];
  final uid = Platform.environment['BICOUNT_PREPROD_TEST_UID'];
  final tid = Platform.environment['BICOUNT_PREPROD_TEST_CREATION_TID'];
  final lostTid = Platform.environment['BICOUNT_PREPROD_TEST_LOST_TID'];
  test('experimental client sends a creation to local Supabase', () async {
    if (key == null || token == null || uid == null || tid == null) {
      throw StateError('This test requires the local preproduction harness.');
    }
    final client = SupabaseClient(
      'http://127.0.0.1:54321',
      key,
      accessToken: () async => token,
    );
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(client.dispose);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    await outbox.commit(
      OfflineOperation(
        userId: uid,
        collection: 'transactions',
        recordId: tid,
        action: 'upsert',
        isCreation: true,
        payload: {
          'tid': tid,
          'uid': uid,
          'gtid': const Uuid().v4(),
          'name': 'Flutter receipt test',
          'type': 0,
          'sender_id': uid,
          'beneficiary_id': uid,
          'date': '2026-01-01T00:00:00Z',
          'amount': 17,
          'currency': 'CDF',
        },
      ),
      (_) async {},
    );
    final operation = (await outbox.pending(uid)).single;
    expect(
      await deliverConditionalCreation(
        db: db,
        client: client,
        operation: operation,
        currentUserId: () => uid,
      ),
      isTrue,
    );
    expect(await outbox.pending(uid), isEmpty);
    final rows = await client
        .from('transactions')
        .select('tid,amount')
        .eq('tid', tid);
    expect(rows, hasLength(1));
    expect(rows.single['amount'], 17);
  });

  test(
    'real committed creation is recovered after its response is lost',
    () async {
      if (key == null || token == null || uid == null || lostTid == null) {
        throw StateError('This test requires the local preproduction harness.');
      }
      final transport = _LoseFirstCreationResponse();
      final client = SupabaseClient(
        'http://127.0.0.1:54321',
        key,
        accessToken: () async => token,
        httpClient: transport,
      );
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(client.dispose);
      addTearDown(transport.close);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await outbox.commit(
        OfflineOperation(
          userId: uid,
          collection: 'transactions',
          recordId: lostTid,
          action: 'upsert',
          isCreation: true,
          payload: {
            'tid': lostTid,
            'uid': uid,
            'gtid': const Uuid().v4(),
            'name': 'Lost response test',
            'type': 0,
            'sender_id': uid,
            'beneficiary_id': uid,
            'date': '2026-01-01T00:00:00Z',
            'amount': 23,
            'currency': 'CDF',
          },
        ),
        (_) async {},
      );
      final operation = (await outbox.pending(uid)).single;
      Future<bool> send() => deliverConditionalCreation(
        db: db,
        client: client,
        operation: operation,
        currentUserId: () => uid,
      );
      await expectLater(send(), throwsA(isA<http.ClientException>()));
      expect((await outbox.pending(uid)).single.id, operation.id);
      expect(await send(), isTrue);
      expect(await outbox.pending(uid), isEmpty);
      final rows = await client
          .from('transactions')
          .select('tid')
          .eq('tid', lostTid);
      expect(rows, hasLength(1));
    },
  );
}
