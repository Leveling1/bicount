import 'dart:io';

import 'package:bicount/core/offline/offline_legacy_copy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'copies only the matching V1 account and preserves its source',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bicount_copy_test_',
      );
      addTearDown(() async {
        final resolved = path.normalize(directory.absolute.path);
        final temporaryRoot = path.normalize(
          Directory.systemTemp.absolute.path,
        );
        if (!path.isWithin(temporaryRoot, resolved)) {
          throw StateError('Test directory escaped the temporary root.');
        }
        await directory.delete(recursive: true);
      });
      final factory = databaseFactoryFfi;
      final sourcePath = path.join(directory.path, 'my_repository.sqlite');
      final source = await factory.openDatabase(sourcePath);
      await source.execute('CREATE TABLE UserModel (uid TEXT)');
      await source.insert('UserModel', {'uid': 'user-1'});
      await source.execute(
        'CREATE TABLE TransactionModel (tid TEXT, amount REAL)',
      );
      await source.insert('TransactionModel', {'tid': 'row-1', 'amount': 42.0});
      await source.close();

      final wrongPath = path.join(directory.path, 'wrong.sqlite');
      await copyLegacyDatabaseForSameUser(
        factory,
        'user-2',
        directory.path,
        wrongPath,
      );
      expect(await factory.databaseExists(wrongPath), isFalse);

      final targetPath = path.join(directory.path, 'user-1.sqlite');
      await copyLegacyDatabaseForSameUser(
        factory,
        'user-1',
        directory.path,
        targetPath,
      );
      final target = await factory.openDatabase(targetPath);
      expect((await target.query('TransactionModel')).single['amount'], 42.0);
      await target.close();
      expect(await factory.databaseExists(sourcePath), isTrue);
    },
  );
}
