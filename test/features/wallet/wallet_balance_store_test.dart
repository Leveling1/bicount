import 'package:bicount/features/wallet/data/data_sources/local_datasource/wallet_balance_store.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const uid = 'account';
  const contact = 'linked-contact';
  final principal = WalletModel.principalId(uid);
  late Database db;

  setUp(() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE FriendsModel (sid TEXT PRIMARY KEY, uid TEXT)',
    );
    await db.execute('''
      CREATE TABLE TransactionModel (
        tid TEXT PRIMARY KEY, sender_id TEXT, beneficiary_id TEXT, type INTEGER,
        currency TEXT, amount REAL, sender_wallet_id TEXT, beneficiary_wallet_id TEXT
      )
    ''');
    await db.execute(
      'CREATE TABLE WalletModel (wallet_id TEXT PRIMARY KEY, owner_uid TEXT)',
    );
    await db.insert('WalletModel', {'wallet_id': 'cash', 'owner_uid': uid});
    await installWalletBalances(db, uid);
  });
  tearDown(() => db.close());

  Future<void> movement(
    String id,
    String sender,
    String beneficiary,
    String currency,
    double amount, {
    String? from,
    String? to,
    int type = 0,
  }) async {
    await db.insert('TransactionModel', {
      'tid': id,
      'sender_id': sender,
      'beneficiary_id': beneficiary,
      'currency': currency,
      'amount': amount,
      'type': type,
      'sender_wallet_id': from,
      'beneficiary_wallet_id': to,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<(String, String), int>> balances() async => {
    for (final row in await readWalletBalances(db))
      (row.walletId, row.currency): row.minor,
  };

  test(
    'linking and replaying 100 operations is idempotent across currencies',
    () async {
      for (var i = 0; i < 100; i++) {
        await movement('$i', 'friend', contact, i.isEven ? 'USD' : 'EUR', 2.5);
      }
      expect(await balances(), isEmpty);
      for (var i = 0; i < 2; i++) {
        await db.insert('FriendsModel', {
          'sid': contact,
          'uid': uid,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        expect(await balances(), {
          (principal, 'USD'): 12500,
          (principal, 'EUR'): 12500,
        });
      }
      await db.update('FriendsModel', {'uid': null});
      expect((await balances()).values, everyElement(0));
    },
  );

  test(
    'replacement, transfer and deletion apply only their net effects',
    () async {
      await movement('a', uid, uid, 'USD', 50, type: 1);
      await movement(
        'transfer',
        uid,
        uid,
        'USD',
        20,
        from: principal,
        to: 'cash',
        type: 8,
      );
      await movement(
        'transfer',
        uid,
        uid,
        'USD',
        25,
        from: principal,
        to: 'cash',
        type: 8,
      );
      expect(await balances(), {
        (principal, 'USD'): 2500,
        ('cash', 'USD'): 2500,
      });
      await db.delete(
        'TransactionModel',
        where: 'tid = ?',
        whereArgs: ['transfer'],
      );
      expect(await balances(), {(principal, 'USD'): 5000, ('cash', 'USD'): 0});
    },
  );
}
