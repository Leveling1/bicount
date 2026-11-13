import 'dart:convert';

import 'package:bicount/core/offline/outbox/offline_creation_attempt.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test(
    'creation attempts retain the original payload across later edits',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'row',
          action: 'upsert',
          isCreation: true,
          payload: {'tid': 'row', 'amount': 10},
        ),
        (_) async {},
      );
      final first = (await outbox.pending('u')).single;
      expect(await recordCreationAttempt(db, first), isTrue);
      expect(await recordCreationAttempt(db, first), isTrue);
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'row',
          action: 'upsert',
          payload: {'tid': 'row', 'amount': 20},
        ),
        (_) async {},
      );
      final second = (await outbox.pending('u')).single;
      expect(await recordCreationAttempt(db, first), isFalse);
      expect(await recordCreationAttempt(db, second), isTrue);
      final attempts = await db.query(
        'bicount_creation_attempts',
        orderBy: 'rowid',
      );
      expect(attempts, hasLength(2));
      expect(attempts.first['creation_operation_id'], first.id);
      expect(attempts.last['creation_operation_id'], first.id);
      expect(
        (jsonDecode(attempts.first['payload'] as String) as Map)['amount'],
        10,
      );
      expect(
        (jsonDecode(attempts.last['payload'] as String) as Map)['amount'],
        20,
      );
    },
  );

  test(
    'an old creation with unknown provenance cannot be recorded as sendable',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'row',
          action: 'upsert',
          isCreation: true,
          payload: {'tid': 'row'},
        ),
        (_) async {},
      );
      await db.update('bicount_sync_outbox', {'creation_operation_id': null});
      expect(
        await recordCreationAttempt(db, (await outbox.pending('u')).single),
        isFalse,
      );
      expect(await db.query('bicount_creation_attempts'), isEmpty);
    },
  );

  test('rejects a changed payload under the same operation id', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'row',
        action: 'upsert',
        isCreation: true,
        payload: {'tid': 'row', 'amount': 10},
      ),
      (_) async {},
    );
    final operation = (await outbox.pending('u')).single;
    expect(await recordCreationAttempt(db, operation), isTrue);
    operation.payload['amount'] = 20;
    expect(await recordCreationAttempt(db, operation), isFalse);
    expect(
      (jsonDecode(
            (await db.query('bicount_creation_attempts')).single['payload']
                as String,
          )
          as Map)['amount'],
      10,
    );
  });

  test('rejects an inconsistent already-recorded attempt', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'row',
        action: 'upsert',
        isCreation: true,
        payload: {'tid': 'row', 'amount': 10},
      ),
      (_) async {},
    );
    final operation = (await outbox.pending('u')).single;
    expect(await recordCreationAttempt(db, operation), isTrue);
    await db.update('bicount_creation_attempts', {
      'payload': '{"tid":"other"}',
    });
    expect(await recordCreationAttempt(db, operation), isFalse);
  });

  test(
    'an ambiguous first send blocks retries even after a later edit',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'row',
          action: 'upsert',
          isCreation: true,
          payload: {'tid': 'row', 'amount': 10},
        ),
        (_) async {},
      );
      final first = (await outbox.pending('u')).single;
      expect(
        await reserveFirstCreationSend(
          db,
          first,
          journalSequence: 4,
          journalGeneration: 1,
        ),
        isTrue,
      );
      expect(
        await reserveFirstCreationSend(
          db,
          first,
          journalSequence: 4,
          journalGeneration: 1,
        ),
        isFalse,
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'row',
          action: 'upsert',
          payload: {'tid': 'row', 'amount': 20},
        ),
        (_) async {},
      );
      final later = (await outbox.pending('u')).single;
      expect(
        await reserveFirstCreationSend(
          db,
          later,
          journalSequence: 5,
          journalGeneration: 1,
        ),
        isFalse,
      );
      expect((await outbox.pending('u')).single.payload['amount'], 20);
      expect(await db.query('bicount_creation_attempts'), hasLength(1));
      expect(
        (await db.query(
          'bicount_creation_attempts',
        )).single['journal_sequence'],
        4,
      );
    },
  );
}
