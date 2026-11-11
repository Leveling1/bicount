import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_legacy_finance_migration.dart';
import 'package:bicount/core/offline/offline_legacy_finance_reconcile.dart';
import 'package:bicount/core/offline/legacy_uuid.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'a similar server row with a different UUID cannot prove identity',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      for (final codec in [
        transactionModelCodec,
        recurringTransfertModelCodec,
      ]) {
        final columns = codec.localColumns.values
            .toSet()
            .map((column) => '"$column"')
            .join(', ');
        await db.execute(
          'CREATE TABLE ${codec.localTable} '
          '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
        );
      }
      await db.execute(
        'CREATE TABLE AccountFundingModel '
        '(funding_id TEXT, sid TEXT, amount REAL, currency TEXT, '
        'source TEXT, date TEXT, category INTEGER)',
      );
      await db.insert('AccountFundingModel', {
        'funding_id': 'old-funding',
        'sid': 'user-1',
        'amount': 42.0,
        'currency': 'USD',
        'source': 'Deposit',
        'date': '2026-04-01',
        'category': 0,
      });
      await OfflineOutbox(db).initialize();

      await migrateLegacyFinance(db, 'user-1');
      await migrateLegacyFinance(db, 'user-1');
      expect(await db.query('TransactionModel'), hasLength(1));
      expect(await hasLegacyFinanceCandidates(db), isTrue);

      await reconcileLegacyFinanceCandidates(
        db: db,
        codec: transactionModelCodec,
        userId: 'user-1',
        remoteRows: [
          {
            'tid': 'server-funding',
            'uid': 'user-1',
            'type': 1,
            'name': 'Deposit',
            'currency': 'USD',
            'amount': 42.0,
            'date': '2026-04-01T00:00:00Z',
            'sender_id': 'user-1',
            'beneficiary_id': 'user-1',
          },
        ],
      );
      expect(await db.query('TransactionModel'), hasLength(1));
      expect(await hasLegacyFinanceCandidates(db), isTrue);
      expect(await OfflineOutbox(db).pending('user-1'), isEmpty);
      expect(await db.query('AccountFundingModel'), hasLength(1));
      await reconcileLegacyFinanceCandidates(
        db: db,
        codec: transactionModelCodec,
        userId: 'user-1',
        remoteRows: [
          {'tid': canonicalLegacyUuid('account_funding', 'old-funding')},
        ],
      );
      expect(await hasLegacyFinanceCandidates(db), isFalse);
    },
  );

  test(
    'unmatched old funding stays local without an automatic write',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final columns = transactionModelCodec.localColumns.values
          .toSet()
          .map((column) => '"$column"')
          .join(', ');
      await db.execute(
        'CREATE TABLE TransactionModel '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
      final recurringColumns = recurringTransfertModelCodec.localColumns.values
          .toSet()
          .map((column) => '"$column"')
          .join(', ');
      await db.execute(
        'CREATE TABLE RecurringTransfertModel '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $recurringColumns)',
      );
      await db.execute(
        'CREATE TABLE AccountFundingModel '
        '(funding_id TEXT, sid TEXT, amount REAL, currency TEXT, '
        'source TEXT, date TEXT, category INTEGER)',
      );
      await db.insert('AccountFundingModel', {
        'funding_id': 'old-funding',
        'sid': 'user-1',
        'amount': 42.0,
        'currency': 'USD',
        'source': 'Deposit',
        'date': '2026-04-01',
        'category': 0,
      });
      await OfflineOutbox(db).initialize();
      await migrateLegacyFinance(db, 'user-1');
      await reconcileLegacyFinanceCandidates(
        db: db,
        codec: transactionModelCodec,
        userId: 'user-1',
        remoteRows: const [],
      );
      final pending = await OfflineOutbox(db).pending('user-1');
      expect(pending, isEmpty);
      expect(await hasLegacyFinanceCandidates(db), isTrue);
      expect(await db.query('TransactionModel'), hasLength(1));
      expect(await db.query('AccountFundingModel'), hasLength(1));
    },
  );

  test('uncertain old deletion remains queued and is not sent', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    for (final codec in [transactionModelCodec, recurringTransfertModelCodec]) {
      final columns = codec.localColumns.values
          .toSet()
          .map((column) => '"$column"')
          .join(', ');
      await db.execute(
        'CREATE TABLE ${codec.localTable} '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
    }
    await db.execute(
      'CREATE TABLE AccountFundingModel '
      '(funding_id TEXT, sid TEXT, amount REAL, currency TEXT, '
      'source TEXT, date TEXT, category INTEGER)',
    );
    await db.insert('AccountFundingModel', {
      'funding_id': 'old-funding',
      'sid': 'user-1',
      'amount': 42.0,
      'currency': 'USD',
      'source': 'Deposit',
      'date': '2026-04-01',
      'category': 0,
    });
    await OfflineOutbox(db).initialize();
    await migrateLegacyFinance(db, 'user-1');
    final localId = canonicalLegacyUuid('account_funding', 'old-funding');
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: 'user-1',
        collection: 'transactions',
        recordId: localId,
        action: 'delete',
        payload: {'tid': localId},
      ),
      (tx) =>
          tx.delete('TransactionModel', where: 'tid = ?', whereArgs: [localId]),
    );

    await reconcileLegacyFinanceCandidates(
      db: db,
      codec: transactionModelCodec,
      userId: 'user-1',
      remoteRows: [
        {
          'tid': 'server-funding',
          'uid': 'user-1',
          'type': 1,
          'name': 'Deposit',
          'currency': 'USD',
          'amount': 42.0,
          'date': '2026-04-01',
          'sender_id': 'user-1',
          'beneficiary_id': 'user-1',
        },
      ],
    );

    final pending = await OfflineOutbox(db).pending('user-1');
    expect(pending, hasLength(1));
    expect(pending.single.action, 'delete');
    expect(pending.single.recordId, localId);
    expect(pending.single.payload['tid'], localId);
    expect(await hasLegacyFinanceCandidates(db), isTrue);
    await reconcileLegacyFinanceCandidates(
      db: db,
      codec: transactionModelCodec,
      userId: 'user-1',
      remoteRows: [
        {'tid': localId},
      ],
    );
    expect(await hasLegacyFinanceCandidates(db), isTrue);
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: 'user-1',
        collection: 'transactions',
        recordId: 'independent',
        action: 'upsert',
        payload: {'tid': 'independent'},
      ),
      (_) async {},
    );
    expect(
      (await OfflineOutbox(db).pending(
        'user-1',
        excludeUnresolvedLegacy: true,
      )).map((operation) => operation.recordId),
      ['independent'],
    );
  });
}
