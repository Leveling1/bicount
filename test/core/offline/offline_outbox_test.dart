import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('archive schema upgrade preserves previously archived data', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute(
      'CREATE TABLE bicount_guarded_operation_archive ('
      'operation_id TEXT PRIMARY KEY, user_id TEXT NOT NULL, collection TEXT NOT NULL, '
      'record_id TEXT NOT NULL, action TEXT NOT NULL, payload TEXT NOT NULL, '
      'created_at TEXT NOT NULL)',
    );
    await db.insert('bicount_guarded_operation_archive', {
      'operation_id': 'old',
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'action': 'upsert',
      'payload': '{}',
      'created_at': '2026-01-01T00:00:00Z',
    });
    await db.execute(
      'CREATE TABLE bicount_remote_baseline '
      '(user_id TEXT, collection TEXT, record_id TEXT, remote_payload TEXT, '
      'PRIMARY KEY (user_id, collection, record_id))',
    );
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': '{"tid":"id"}',
    });
    await OfflineOutbox(db).initialize();
    final row = (await db.query('bicount_guarded_operation_archive')).single;
    expect(row['operation_id'], 'old');
    expect(row['is_creation'], 0);
    expect(row['creation_operation_id'], isNull);
    final baseline = (await db.query('bicount_remote_baseline')).single;
    expect(baseline['remote_payload'], '{"tid":"id"}');
    expect(baseline['journal_sequence'], isNull);
    expect(baseline['journal_generation'], isNull);
  });

  test(
    'unknown provenance is not reconstructed or upgraded by a later edit',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'old-create',
          action: 'upsert',
          isCreation: true,
          payload: {'tid': 'old-create'},
        ),
        (_) async {},
      );
      await db.update(
        'bicount_sync_outbox',
        {'creation_operation_id': null},
        where: 'record_id = ?',
        whereArgs: ['old-create'],
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'old-create',
          action: 'upsert',
          payload: {'tid': 'old-create'},
        ),
        (_) async {},
      );
      final old = (await outbox.pending('u')).single;
      expect(old.isCreation, isTrue);
      expect(old.creationOperationId, isNull);

      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'unknown',
          action: 'upsert',
          payload: {'tid': 'unknown'},
        ),
        (_) async {},
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'unknown',
          action: 'upsert',
          isCreation: true,
          payload: {'tid': 'unknown'},
        ),
        (_) async {},
      );
      final unknown = (await outbox.pending(
        'u',
      )).firstWhere((o) => o.recordId == 'unknown');
      expect(unknown.isCreation, isFalse);
      expect(unknown.creationOperationId, isNull);
    },
  );

  test('local row and outgoing intent commit atomically', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('CREATE TABLE records (id TEXT PRIMARY KEY, amount REAL)');
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    final operation = OfflineOperation(
      userId: 'user-1',
      collection: 'transactions',
      recordId: 'row-1',
      action: 'upsert',
      payload: {'tid': 'row-1', 'amount': 12.5},
    );

    await outbox.commit(
      operation,
      (tx) => tx.insert('records', {'id': 'row-1', 'amount': 12.5}),
    );

    expect((await db.query('records')).single['amount'], 12.5);
    expect((await outbox.pending('user-1')).single.id, operation.id);
  });

  test('failure rolls back both the row and intent', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('CREATE TABLE records (id TEXT PRIMARY KEY)');
    final outbox = OfflineOutbox(db);
    await outbox.initialize();

    await expectLater(
      outbox.commit(
        OfflineOperation(
          userId: 'user-1',
          collection: 'transactions',
          recordId: 'row-1',
          action: 'upsert',
          payload: {'tid': 'row-1'},
        ),
        (tx) async {
          await tx.insert('records', {'id': 'row-1'});
          throw StateError('write failed');
        },
      ),
      throwsStateError,
    );

    expect(await db.query('records'), isEmpty);
    expect(await outbox.pending('user-1'), isEmpty);
  });

  test('repeated edits keep only the latest unsent state', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    for (final amount in [12.5, 18.0]) {
      await outbox.commit(
        OfflineOperation(
          userId: 'user-1',
          collection: 'transactions',
          recordId: 'row-1',
          action: 'upsert',
          payload: {'tid': 'row-1', 'amount': amount},
        ),
        (_) async {},
      );
    }
    final pending = await outbox.pending('user-1');
    expect(pending, hasLength(1));
    expect(pending.single.payload['amount'], 18.0);
  });

  test(
    'creation provenance survives edits until the server acknowledges it',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      String? originalOperationId;
      for (final isCreation in [true, false]) {
        final operation = OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'id',
          action: 'upsert',
          payload: {'tid': 'id'},
          isCreation: isCreation,
        );
        originalOperationId ??= operation.id;
        await outbox.commit(operation, (_) async {});
      }
      final pending = (await outbox.pending('u')).single;
      expect(pending.isCreation, isTrue);
      expect(pending.creationOperationId, originalOperationId);
      expect(pending.id, isNot(originalOperationId));
      await outbox.acknowledge('u', pending.id);
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: 'id',
          action: 'upsert',
          payload: {'tid': 'id'},
        ),
        (_) async {},
      );
      expect((await outbox.pending('u')).single.isCreation, isFalse);
    },
  );

  test(
    'editing a guarded record preserves its previous pending intent',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      final previous = OfflineOperation(
        userId: 'user-1',
        collection: 'transactions',
        recordId: 'row-1',
        action: 'upsert',
        payload: {'tid': 'row-1', 'amount': 10},
        isCreation: true,
      );
      await outbox.commit(previous, (tx) async {
        await tx.insert('bicount_legacy_pending_guard', {
          'user_id': 'user-1',
          'collection': 'transactions',
          'record_id': 'row-1',
        });
      });
      await outbox.commit(
        OfflineOperation(
          userId: 'user-1',
          collection: 'transactions',
          recordId: 'row-1',
          action: 'delete',
          payload: {'tid': 'row-1'},
        ),
        (_) async {},
      );
      final archived = await db.query('bicount_guarded_operation_archive');
      expect(archived.single['operation_id'], previous.id);
      expect(archived.single['payload'], contains('10'));
      expect(archived.single['is_creation'], 1);
      expect(archived.single['creation_operation_id'], previous.id);
      expect((await outbox.pending('user-1')).single.action, 'delete');
    },
  );

  test(
    'existing legacy imports are guarded once without losing intents',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await db.execute(
        'CREATE TABLE bicount_legacy_import (job_id INTEGER PRIMARY KEY)',
      );
      await db.execute(
        'CREATE TABLE bicount_sync_outbox ('
        'sequence INTEGER PRIMARY KEY AUTOINCREMENT, operation_id TEXT UNIQUE, '
        'user_id TEXT, collection TEXT, record_id TEXT, action TEXT, '
        'payload TEXT, created_at TEXT)',
      );
      await db.insert(
        'bicount_sync_outbox',
        (OfflineOperation(
            userId: 'user-1',
            collection: 'transactions',
            recordId: 'old',
            action: 'upsert',
            payload: {'tid': 'old'},
          ).toDatabase()
          ..remove('is_creation')
          ..remove('creation_operation_id')),
      );
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      expect(await outbox.pending('user-1'), hasLength(1));
      await db.execute(
        'CREATE TABLE bicount_legacy_finance_candidates '
        '(target_table TEXT, target_id TEXT)',
      );
      expect(
        await outbox.pending('user-1', excludeUnresolvedLegacy: true),
        isEmpty,
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'user-1',
          collection: 'transactions',
          recordId: 'new',
          action: 'upsert',
          payload: {'tid': 'new'},
        ),
        (_) async {},
      );
      await outbox.initialize();
      expect(
        (await outbox.pending(
          'user-1',
          excludeUnresolvedLegacy: true,
        )).map((op) => op.recordId),
        ['new'],
      );
    },
  );
}
