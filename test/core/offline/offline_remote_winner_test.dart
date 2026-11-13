import 'dart:convert';

import 'package:bicount/core/offline/offline_remote_winner.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late OfflineOutbox outbox;
  late OfflineOperation operation;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    outbox = OfflineOutbox(db);
    await outbox.initialize();
    await db.execute(
      'CREATE TABLE sample (id TEXT PRIMARY KEY, value INTEGER)',
    );
    operation = OfflineOperation(
      userId: 'user',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'tid': 'id', 'amount': 10},
    );
    await outbox.commit(operation, (tx) async {
      await tx.insert('sample', {'id': 'id', 'value': 10});
    });
  });
  tearDown(() => db.close());

  test(
    'archives the losing intent and applies the server row atomically',
    () async {
      final result = await applyRemoteConflictWinner(
        db: db,
        operation: operation,
        remoteRow: {'tid': 'id', 'amount': 20},
        applyRemote: (tx) async {
          await tx.update('sample', {'value': 20});
        },
      );
      expect(result, isTrue);
      expect((await db.query('sample')).single['value'], 20);
      expect(await outbox.pending('user'), isEmpty);
      final archived = (await db.query('bicount_sync_conflict_archive')).single;
      expect(
        (jsonDecode(archived['local_payload'] as String) as Map)['amount'],
        10,
      );
      expect(
        (jsonDecode(archived['remote_payload'] as String) as Map)['amount'],
        20,
      );
    },
  );

  test(
    'does not erase a newer local edit while the response is in flight',
    () async {
      final newer = OfflineOperation(
        userId: 'user',
        collection: 'transactions',
        recordId: 'id',
        action: 'upsert',
        payload: {'tid': 'id', 'amount': 30},
      );
      await outbox.commit(newer, (tx) async {
        await tx.update('sample', {'value': 30});
      });
      final result = await applyRemoteConflictWinner(
        db: db,
        operation: operation,
        remoteRow: {'tid': 'id', 'amount': 20},
        applyRemote: (tx) async {
          await tx.update('sample', {'value': 20});
        },
      );
      expect(result, isFalse);
      expect((await db.query('sample')).single['value'], 30);
      expect((await outbox.pending('user')).single.id, newer.id);
      expect(await db.query('bicount_sync_conflict_archive'), isEmpty);
    },
  );

  test(
    'failure rolls back archive and leaves the local intent intact',
    () async {
      await expectLater(
        applyRemoteConflictWinner(
          db: db,
          operation: operation,
          remoteRow: {'tid': 'id', 'amount': 20},
          applyRemote: (tx) async {
            await tx.update('sample', {'value': 20});
            throw StateError('failed');
          },
        ),
        throwsStateError,
      );
      expect((await db.query('sample')).single['value'], 10);
      expect((await outbox.pending('user')).single.id, operation.id);
      expect(await db.query('bicount_sync_conflict_archive'), isEmpty);
    },
  );
}
