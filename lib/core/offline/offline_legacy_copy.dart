import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';

import 'offline_legacy_owner.dart';

/// Leaves the V1 file intact until a same-owner copy exists for V2.
Future<void> copyLegacyDatabaseForSameUser(
  DatabaseFactory factory,
  String uid,
  String directory,
  String target,
) async {
  final legacy = path.join(directory, 'my_repository.sqlite');
  if (!await legacyDatabaseBelongsTo(factory, legacy, uid)) return;
  final temporary = '$target.importing';
  if (!path.isWithin(directory, temporary)) {
    throw StateError('Local database path escaped the app directory.');
  }
  await File(legacy).copy(temporary);
  for (final suffix in const ['-wal', '-shm']) {
    final sidecar = File('$legacy$suffix');
    if (await sidecar.exists()) {
      await sidecar.copy('$temporary$suffix');
    } else {
      final stale = File('$temporary$suffix');
      if (await stale.exists()) await stale.delete();
    }
    final previous = File('$target$suffix');
    if (await previous.exists()) await previous.delete();
    final copied = File('$temporary$suffix');
    if (await copied.exists()) await copied.rename('$target$suffix');
  }
  await File(temporary).rename(target);
}
