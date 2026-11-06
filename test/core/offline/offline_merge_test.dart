import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_merge.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'remote snapshot protects pending edits and archives confirmed deletes',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final codec = codecFor<TransactionModel>();
      final columns = codec.localColumns.values
          .toSet()
          .map((column) => '"$column"')
          .join(', ');
      await db.execute(
        'CREATE TABLE ${codec.localTable} '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
      await db.execute(
        'CREATE TABLE bicount_removed_record_archive '
        '(table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, '
        'PRIMARY KEY (table_name, record_id))',
      );
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      await db.insert(codec.localTable, {
        'tid': 'row-1',
        'name': 'Local',
        'amount': 10.0,
      });
      await db.insert(codec.localTable, {
        'tid': 'row-3',
        'name': 'Removed',
        'amount': 30.0,
      });
      final operation = OfflineOperation(
        userId: 'user-1',
        collection: codec.table,
        recordId: 'row-1',
        action: 'upsert',
        payload: {'tid': 'row-1', 'amount': 10.0},
      );
      await outbox.commit(operation, (_) async {});

      await const OfflineMerge().snapshot(
        db: db,
        codec: codec,
        userId: 'user-1',
        rows: [
          {'tid': 'row-1', 'name': 'Remote', 'amount': 99.0},
          {'tid': 'row-2', 'name': 'New', 'amount': 20.0},
        ],
        confirmedDeletes: ['row-3'],
      );

      final rows = await db.query(codec.localTable, orderBy: 'tid');
      expect(rows.map((row) => row['tid']), ['row-1', 'row-2']);
      expect(rows.first['name'], 'Local');
      expect(rows.last['name'], 'New');
      expect(
        (await db.query('bicount_removed_record_archive')).single['record_id'],
        'row-3',
      );

      expect(
        await const OfflineMerge().event(
          db: db,
          codec: codec,
          userId: 'user-1',
          id: 'row-1',
          row: {'tid': 'row-1', 'name': 'Changed'},
        ),
        isFalse,
      );
      await outbox.acknowledge('user-1', operation.id);
      expect(
        await const OfflineMerge().event(
          db: db,
          codec: codec,
          userId: 'user-1',
          id: 'row-1',
          row: {'tid': 'row-1', 'name': 'Changed'},
        ),
        isTrue,
      );
      expect(
        (await db.query(
          codec.localTable,
          where: 'tid = ?',
          whereArgs: ['row-1'],
        )).single['name'],
        'Changed',
      );
      expect(
        await const OfflineMerge().event(
          db: db,
          codec: codec,
          userId: 'user-1',
          id: 'row-2',
        ),
        isTrue,
      );
      expect(
        await db.query(
          codec.localTable,
          where: 'tid = ?',
          whereArgs: ['row-2'],
        ),
        isEmpty,
      );
      expect(
        await db.query(
          'bicount_removed_record_archive',
          where: 'record_id = ?',
          whereArgs: ['row-2'],
        ),
        hasLength(1),
      );
    },
  );
}
