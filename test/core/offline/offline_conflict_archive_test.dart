import 'dart:convert';

import 'package:bicount/core/offline/offline_conflict_archive.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test('preserves both versions and deduplicates identical retries', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({'tid': 'id', 'amount': 10}),
    });
    final op = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'tid': 'id', 'amount': 15},
    );
    await outbox.commit(op, (_) async {});
    for (final amount in [20, 20, 25]) {
      await archiveConditionalConflict(
        db: db,
        operation: op,
        reason: 'conflict',
        remoteRow: {'tid': 'id', 'amount': amount},
      );
    }
    final rows = await db.query(
      'bicount_sync_conflict_archive',
      orderBy: 'conflict_id',
    );
    expect(rows, hasLength(2));
    expect(
      (jsonDecode(rows.first['baseline_payload'] as String) as Map)['amount'],
      10,
    );
    expect(
      (jsonDecode(rows.first['local_payload'] as String) as Map)['amount'],
      15,
    );
    expect(
      (jsonDecode(rows.first['remote_payload'] as String) as Map)['amount'],
      20,
    );
    expect(
      (jsonDecode(rows.last['remote_payload'] as String) as Map)['amount'],
      25,
    );
    expect((await outbox.pending('u')).single.id, op.id);
  });
}
