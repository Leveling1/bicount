import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_remote_winner_merge.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestConflictRow {
  TestConflictRow(this.data);
  final Map<String, dynamic> data;
}

void main() {
  sqfliteFfiInit();
  final codec = OfflineCodec<TestConflictRow>(
    table: 'transactions',
    key: 'id',
    columns: const {'id': 'id', 'value': 'value'},
    localColumns: const {'id': 'id', 'value': 'value'},
    fromLocal: TestConflictRow.new,
    fromRemote: TestConflictRow.new,
    toLocal: (row) => row.data,
    toRemote: (row) => row.data,
  );
  late Database db;
  late OfflineOutbox outbox;
  late OfflineOperation op;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    outbox = OfflineOutbox(db);
    await outbox.initialize();
    await db.execute(
      'CREATE TABLE "${codec.localTable}" (id TEXT PRIMARY KEY, value INTEGER)',
    );
    await db.execute(
      'CREATE TABLE bicount_removed_record_archive (table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, PRIMARY KEY (table_name, record_id))',
    );
    op = OfflineOperation(
      userId: 'u',
      collection: 'transactions',
      recordId: 'id',
      action: 'upsert',
      payload: {'id': 'id', 'value': 10},
    );
    await outbox.commit(op, (tx) async {
      await tx.insert(codec.localTable, {'id': 'id', 'value': 10});
    });
  });
  tearDown(() => db.close());

  test('applies server row and baseline with an atomic archive', () async {
    expect(
      await mergeRemoteConflictWinner(
        db: db,
        operation: op,
        codec: codec,
        remoteRow: {'id': 'id', 'value': 20},
        journalSequence: 7,
        journalGeneration: 1,
        currentUserId: () => 'u',
      ),
      isTrue,
    );
    expect((await db.query(codec.localTable)).single['value'], 20);
    expect(
      (await db.query('bicount_remote_baseline')).single['journal_sequence'],
      7,
    );
    expect(await outbox.pending('u'), isEmpty);
    expect(await db.query('bicount_sync_conflict_archive'), hasLength(1));
  });

  test('a changed account cannot discard a queued operation', () async {
    expect(
      () => mergeRemoteConflictWinner(
        db: db,
        operation: op,
        codec: codec,
        remoteRow: {'id': 'id', 'value': 20},
        journalSequence: 7,
        journalGeneration: 1,
        currentUserId: () => 'other',
      ),
      throwsStateError,
    );
    expect((await outbox.pending('u')).single.id, op.id);
    expect((await db.query(codec.localTable)).single['value'], 10);
  });

  test('an invalid server identity cannot modify the local row', () async {
    expect(
      () => mergeRemoteConflictWinner(
        db: db,
        operation: op,
        codec: codec,
        remoteRow: {'id': 'wrong', 'value': 20},
        journalSequence: 7,
        journalGeneration: 1,
        currentUserId: () => 'u',
      ),
      throwsArgumentError,
    );
    expect((await outbox.pending('u')).single.id, op.id);
  });

  test('a protected legacy candidate prevents applying the server row', () async {
    await db.execute(
      'CREATE TABLE bicount_legacy_finance_candidates (target_table TEXT, target_id TEXT)',
    );
    await db.insert('bicount_legacy_finance_candidates', {
      'target_table': 'transactions',
      'target_id': 'id',
    });
    await expectLater(
      mergeRemoteConflictWinner(
        db: db,
        operation: op,
        codec: codec,
        remoteRow: {'id': 'id', 'value': 20},
        journalSequence: 7,
        journalGeneration: 1,
        currentUserId: () => 'u',
      ),
      throwsStateError,
    );
    expect((await outbox.pending('u')).single.id, op.id);
    expect((await db.query(codec.localTable)).single['value'], 10);
    expect(await db.query('bicount_sync_conflict_archive'), isEmpty);
  });

  test(
    'a verified remote deletion preserves the local edit in the archive',
    () async {
      expect(
        await mergeRemoteConflictWinner(
          db: db,
          operation: op,
          codec: codec,
          remoteRow: null,
          journalSequence: 8,
          journalGeneration: 1,
          currentUserId: () => 'u',
        ),
        isTrue,
      );
      expect(await db.query(codec.localTable), isEmpty);
      expect(await outbox.pending('u'), isEmpty);
      expect(await db.query('bicount_sync_conflict_archive'), hasLength(1));
      expect(await db.query('bicount_removed_record_archive'), hasLength(1));
      expect(
        (await db.query('bicount_remote_baseline')).single['remote_payload'],
        isNull,
      );
    },
  );

  test(
    'an account switch during merge rolls back all conflict changes',
    () async {
      var checks = 0;
      await expectLater(
        mergeRemoteConflictWinner(
          db: db,
          operation: op,
          codec: codec,
          remoteRow: {'id': 'id', 'value': 20},
          journalSequence: 8,
          journalGeneration: 1,
          currentUserId: () => ++checks < 3 ? 'u' : 'other',
        ),
        throwsStateError,
      );
      expect((await db.query(codec.localTable)).single['value'], 10);
      expect((await outbox.pending('u')).single.id, op.id);
      expect(await db.query('bicount_sync_conflict_archive'), isEmpty);
      expect(await db.query('bicount_remote_baseline'), isEmpty);
    },
  );
}
