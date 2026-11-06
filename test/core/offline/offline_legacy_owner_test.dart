import 'dart:io';

import 'package:bicount/core/offline/offline_legacy_owner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'uses the profile owner and never attributes another account data',
    () async {
      final directory = await Directory.systemTemp.createTemp('bicount_owner_');
      addTearDown(() async {
        final root = path.normalize(Directory.systemTemp.absolute.path);
        final target = path.normalize(directory.absolute.path);
        if (!path.isWithin(root, target)) throw StateError('Unsafe test path');
        await directory.delete(recursive: true);
      });
      final filename = path.join(directory.path, 'old.sqlite');
      final db = await databaseFactoryFfi.openDatabase(filename);
      await db.execute('CREATE TABLE UserModel (uid TEXT)');
      await db.insert('UserModel', {'uid': 'owner-1'});
      await db.close();

      expect(
        await legacyDatabaseBelongsTo(databaseFactoryFfi, filename, 'owner-1'),
        isTrue,
      );
      expect(
        await legacyDatabaseBelongsTo(databaseFactoryFfi, filename, 'owner-2'),
        isFalse,
      );
    },
  );

  test(
    'recovers ownership from transaction rows when profile is absent',
    () async {
      final directory = await Directory.systemTemp.createTemp('bicount_owner_');
      addTearDown(() async {
        final root = path.normalize(Directory.systemTemp.absolute.path);
        final target = path.normalize(directory.absolute.path);
        if (!path.isWithin(root, target)) throw StateError('Unsafe test path');
        await directory.delete(recursive: true);
      });
      final filename = path.join(directory.path, 'old.sqlite');
      final db = await databaseFactoryFfi.openDatabase(filename);
      await db.execute('CREATE TABLE TransactionModel (uid TEXT)');
      await db.insert('TransactionModel', {'uid': 'owner-1'});
      await db.close();

      expect(
        await legacyDatabaseBelongsTo(databaseFactoryFfi, filename, 'owner-1'),
        isTrue,
      );
    },
  );
}
