import 'package:sqflite_common/sqlite_api.dart';

/// Additive tables used to preserve unresolved and superseded operations.
Future<void> ensureOfflineArchiveSchema(Database db) async {
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_legacy_pending_guard ('
    'user_id TEXT NOT NULL, collection TEXT NOT NULL, record_id TEXT NOT NULL, '
    'PRIMARY KEY (user_id, collection, record_id))',
  );
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_guarded_operation_archive ('
    'operation_id TEXT PRIMARY KEY, user_id TEXT NOT NULL, '
    'collection TEXT NOT NULL, record_id TEXT NOT NULL, action TEXT NOT NULL, '
    'payload TEXT NOT NULL, created_at TEXT NOT NULL, '
    'is_creation INTEGER NOT NULL DEFAULT 0, creation_operation_id TEXT)',
  );
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_remote_baseline ('
    'user_id TEXT NOT NULL, collection TEXT NOT NULL, record_id TEXT NOT NULL, '
    'remote_payload TEXT, journal_sequence INTEGER, journal_generation INTEGER, '
    'PRIMARY KEY (user_id, collection, record_id))',
  );
  final baselineColumns = await db.rawQuery(
    'PRAGMA table_info(bicount_remote_baseline)',
  );
  for (final name in ['journal_sequence', 'journal_generation']) {
    if (!baselineColumns.any((column) => column['name'] == name)) {
      await db.execute(
        'ALTER TABLE bicount_remote_baseline ADD COLUMN $name INTEGER',
      );
    }
  }
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_sync_conflict_archive ('
    'conflict_id INTEGER PRIMARY KEY AUTOINCREMENT, operation_id TEXT NOT NULL, '
    'user_id TEXT NOT NULL, collection TEXT NOT NULL, record_id TEXT NOT NULL, '
    'action TEXT NOT NULL, local_payload TEXT NOT NULL, local_created_at TEXT NOT NULL, '
    'baseline_payload TEXT, remote_payload TEXT, reason TEXT NOT NULL, '
    'recorded_at TEXT NOT NULL, is_creation INTEGER NOT NULL DEFAULT 0, '
    'creation_operation_id TEXT)',
  );
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_creation_attempts ('
    'user_id TEXT NOT NULL, creation_operation_id TEXT NOT NULL, '
    'operation_id TEXT NOT NULL, collection TEXT NOT NULL, record_id TEXT NOT NULL, '
    'payload TEXT NOT NULL, operation_created_at TEXT NOT NULL, '
    'attempted_at TEXT NOT NULL, PRIMARY KEY (user_id, operation_id))',
  );
  for (final table in [
    'bicount_guarded_operation_archive',
    'bicount_sync_conflict_archive',
  ]) {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (!columns.any((column) => column['name'] == 'is_creation')) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN is_creation INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columns.any((column) => column['name'] == 'creation_operation_id')) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN creation_operation_id TEXT',
      );
    }
  }
  await db.execute(
    'CREATE INDEX IF NOT EXISTS bicount_conflict_operation '
    'ON bicount_sync_conflict_archive(user_id, operation_id)',
  );
}
