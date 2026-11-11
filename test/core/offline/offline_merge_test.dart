import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'dart:convert';
import 'package:bicount/core/offline/offline_merge.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'remote baseline remains unchanged while a local edit is pending',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final codec = codecFor<TransactionModel>();
      final columns = codec.localColumns.values
          .toSet()
          .map((c) => '"$c"')
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
      const merge = OfflineMerge();
      await merge.event(
        db: db,
        codec: codec,
        userId: 'u',
        id: 'row',
        row: {'tid': 'row', 'amount': 10},
        observedSequence: 2,
        observedGeneration: 1,
      );
      await outbox.commit(
        OfflineOperation(
          userId: 'u',
          collection: codec.table,
          recordId: 'row',
          action: 'upsert',
          payload: {'tid': 'row', 'amount': 20},
        ),
        (_) async {},
      );
      await merge.event(
        db: db,
        codec: codec,
        userId: 'u',
        id: 'row',
        row: {'tid': 'row', 'amount': 30},
        observedSequence: 4,
        observedGeneration: 1,
      );
      final row = (await db.query('bicount_remote_baseline')).single;
      expect(
        (jsonDecode(row['remote_payload'] as String) as Map)['amount'],
        10,
      );
      expect(row['user_id'], 'u');
      expect(row['journal_sequence'], 2);
      expect(row['journal_generation'], 1);
    },
  );

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
      await db.execute(
        'CREATE TABLE bicount_legacy_finance_candidates '
        '(target_table TEXT, target_id TEXT)',
      );
      await db.insert('bicount_legacy_finance_candidates', {
        'target_table': 'transactions',
        'target_id': 'row-4',
      });
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
      await db.insert(codec.localTable, {'tid': 'row-4', 'name': 'Unresolved'});
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
        confirmedDeletes: ['row-3', 'row-4'],
      );

      final rows = await db.query(codec.localTable, orderBy: 'tid');
      expect(rows.map((row) => row['tid']), ['row-1', 'row-2', 'row-4']);
      expect(rows.first['name'], 'Local');
      expect(rows[1]['name'], 'New');
      expect(rows.last['name'], 'Unresolved');
      expect(
        await const OfflineMerge().event(
          db: db,
          codec: codec,
          userId: 'user-1',
          id: 'row-4',
        ),
        isFalse,
      );
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
