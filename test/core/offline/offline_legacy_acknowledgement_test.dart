import 'package:bicount/core/offline/offline_legacy_acknowledgement.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test(
    'only an identical guarded upsert is acknowledged and archived',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final outbox = OfflineOutbox(db);
      await outbox.initialize();
      for (final entry in {
        'same': 10,
        'different': 11,
        'missing': 12,
      }.entries) {
        final op = OfflineOperation(
          userId: 'u',
          collection: 'transactions',
          recordId: entry.key,
          action: 'upsert',
          payload: {'tid': entry.key, 'amount': entry.value},
        );
        await outbox.commit(
          op,
          (tx) => tx.insert('bicount_legacy_pending_guard', {
            'user_id': 'u',
            'collection': 'transactions',
            'record_id': entry.key,
          }),
        );
      }
      await acknowledgeIdenticalLegacyUpserts(
        db: db,
        userId: 'u',
        table: 'transactions',
        key: 'tid',
        remoteRows: [
          {'tid': 'same', 'amount': 10.0},
          {'tid': 'different', 'amount': 99},
          {'tid': 'missing'},
        ],
      );
      final pending = await outbox.pending('u');
      expect(pending.map((op) => op.recordId), ['different', 'missing']);
      expect(
        (await db.query(
          'bicount_guarded_operation_archive',
        )).single['record_id'],
        'same',
      );
      expect((await db.query('bicount_legacy_pending_guard')).length, 2);
    },
  );
}
