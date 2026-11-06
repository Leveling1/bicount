import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

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
}
