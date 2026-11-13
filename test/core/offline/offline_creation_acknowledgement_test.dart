import 'package:bicount/core/offline/outbox/offline_creation_acknowledgement.dart';
import 'package:bicount/core/offline/outbox/offline_creation_attempt.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late OfflineOutbox outbox;
  late OfflineOperation sent;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    outbox = OfflineOutbox(db);
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
    sent = (await outbox.pending('u')).single;
    await reserveFirstCreationSend(
      db,
      sent,
      journalSequence: 3,
      journalGeneration: 1,
    );
  });
  tearDown(() => db.close());

  Future<bool> acknowledge({String? Function()? user}) =>
      acknowledgeOfflineCreation(
        db: db,
        sent: sent,
        keyColumn: 'tid',
        remoteRow: {'tid': 'row', 'amount': 10},
        journalSequence: 3,
        journalGeneration: 1,
        currentUserId: user ?? () => 'u',
      );

  test(
    'acknowledges only the attempted creation and saves the baseline',
    () async {
      expect(await acknowledge(), isTrue);
      expect(await outbox.pending('u'), isEmpty);
      expect(
        (await db.query('bicount_remote_baseline')).single['journal_sequence'],
        3,
      );
      expect(await acknowledge(), isFalse);
    },
  );

  test('a later edit stays queued as an update', () async {
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
    expect(await acknowledge(), isTrue);
    final pending = (await outbox.pending('u')).single;
    expect(pending.id, later.id);
    expect(pending.payload['amount'], 20);
    expect(pending.isCreation, isFalse);
    expect(pending.creationOperationId, isNull);
  });

  test('a later deletion remains queued as a deletion', () async {
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'row',
        action: 'delete',
        payload: {'tid': 'row'},
      ),
      (_) async {},
    );
    expect(await acknowledge(), isTrue);
    final pending = (await outbox.pending('u')).single;
    expect(pending.action, 'delete');
    expect(pending.isCreation, isFalse);
  });

  test(
    'unknown attempts and account changes leave the intent untouched',
    () async {
      await db.delete('bicount_creation_attempts');
      expect(await acknowledge(), isFalse);
      expect((await outbox.pending('u')).single.id, sent.id);
      expect(() => acknowledge(user: () => 'other'), throwsStateError);
      expect(await db.query('bicount_remote_baseline'), isEmpty);
    },
  );

  test(
    'account switch inside the transaction rolls back the acknowledgement',
    () async {
      var checks = 0;
      await expectLater(
        acknowledge(user: () => ++checks < 3 ? 'u' : 'other'),
        throwsStateError,
      );
      expect((await outbox.pending('u')).single.id, sent.id);
      expect(await db.query('bicount_remote_baseline'), isEmpty);
    },
  );
  test(
    'a newer unrelated watermark cannot replace the recorded marker',
    () async {
      final applied = await acknowledgeOfflineCreation(
        db: db,
        sent: sent,
        keyColumn: 'tid',
        remoteRow: {'tid': 'row', 'amount': 10},
        journalSequence: 9,
        journalGeneration: 1,
        currentUserId: () => 'u',
      );
      expect(applied, isFalse);
      expect((await outbox.pending('u')).single.id, sent.id);
      expect(await db.query('bicount_remote_baseline'), isEmpty);
    },
  );
}
