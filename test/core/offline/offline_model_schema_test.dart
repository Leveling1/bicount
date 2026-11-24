import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_model_schema.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test('adds the optional operator to existing wallet caches', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final codec = walletModelCodec;
    final columns = codec.localColumns.values
        .where((column) => column != 'mobile_operator')
        .map((column) => '"$column"')
        .join(', ');
    await db.execute('CREATE TABLE "${codec.localTable}" ($columns)');
    final oldWallet = const WalletModel(
      id: 'wallet',
      ownerUid: 'owner',
      name: 'Mobile',
      createdAt: '',
      kind: WalletKind.mobileMoney,
    ).toRow(local: true)..remove('mobile_operator');
    await db.insert(codec.localTable, oldWallet);

    await ensureOfflineModelSchema(db, [codec]);
    final row = (await db.query(codec.localTable)).single;
    expect(codec.fromLocal(row).mobileOperator, isNull);
    expect(codec.fromLocal(row).name, 'Mobile');

    const wallet = WalletModel(
      id: 'wallet',
      ownerUid: 'owner',
      name: 'Mobile',
      createdAt: '',
      kind: WalletKind.mobileMoney,
      mobileOperator: WalletMobileOperator.afrimoney,
    );
    await db.update(codec.localTable, codec.toLocal(wallet));
    expect(codec.fromLocal((await db.query(codec.localTable)).single), wallet);
    expect(codec.fromRemote(codec.toRemote(wallet)), wallet);
  });
  test(
    'extends old tables without deleting existing rows and is repeatable',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      final codec = transactionModelCodec;
      await db.execute(
        'CREATE TABLE "${codec.localTable}" (_local_id INTEGER PRIMARY KEY AUTOINCREMENT, "${codec.localKey}" TEXT, "name" TEXT)',
      );
      await db.insert(codec.localTable, {
        codec.localKey: 'existing',
        'name': 'preserved',
      });
      await ensureOfflineModelSchema(db, [codec]);
      await ensureOfflineModelSchema(db, [codec]);
      final row = (await db.query(codec.localTable)).single;
      expect(row[codec.localKey], 'existing');
      expect(row['name'], 'preserved');
      final columns = await db.rawQuery(
        'PRAGMA table_info("${codec.localTable}")',
      );
      expect(
        columns.map((column) => column['name']).toSet(),
        containsAll(codec.localColumns.values),
      );
      final indexes = await db.rawQuery(
        'PRAGMA index_list("${codec.localTable}")',
      );
      expect(
        indexes.any(
          (index) =>
              index['name'] == 'bicount_${codec.localTable}_${codec.localKey}',
        ),
        isTrue,
      );
    },
  );
}
