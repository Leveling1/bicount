import 'package:sqflite_common/sqlite_api.dart';

import 'offline_codecs.g.dart';

/// Create and extend model tables using a few SQLite batches. Existing rows and
/// columns are never removed, and each codec still owns its table/key names.
Future<void> ensureOfflineModelSchema(
  Database db,
  Iterable<OfflineCodec<dynamic>> codecs,
) async {
  final models = codecs.toList(growable: false);
  final create = db.batch();
  for (final codec in models) {
    final columns = codec.localColumns.values.toSet();
    final definitions = columns.map((name) => '"$name"').join(', ');
    create.execute(
      'CREATE TABLE IF NOT EXISTS "${codec.localTable}" '
      '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $definitions)',
    );
  }
  await create.commit(noResult: true);

  final inspect = db.batch();
  for (final codec in models) {
    inspect.rawQuery('PRAGMA table_info("${codec.localTable}")');
  }
  final schemas = await inspect.commit();
  if (schemas.length != models.length)
    throw StateError('Incomplete local schema inspection.');
  final extend = db.batch();
  for (var i = 0; i < models.length; i++) {
    final codec = models[i];
    final rows = schemas[i];
    if (rows is! List) throw StateError('Invalid local schema inspection.');
    final existing = rows.map((row) => (row as Map)['name']).toSet();
    for (final column in codec.localColumns.values.toSet().where(
      (name) => !existing.contains(name),
    )) {
      extend.execute('ALTER TABLE "${codec.localTable}" ADD COLUMN "$column"');
    }
    extend.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      '"bicount_${codec.localTable}_${codec.localKey}" '
      'ON "${codec.localTable}"("${codec.localKey}")',
    );
  }
  await extend.commit(noResult: true);
}
