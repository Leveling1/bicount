import 'package:sqflite_common/sqlite_api.dart';

import 'offline_operation.dart';
import 'offline_archive_schema.dart';

/// Stores local changes and their outgoing operations in the same database.
class OfflineOutbox {
  const OfflineOutbox(this.database);

  final Database database;
  static const _table = 'bicount_sync_outbox';

  /// Additive initialization; existing user and queue tables are untouched.
  Future<void> initialize() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        sequence INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_id TEXT NOT NULL UNIQUE,
        user_id TEXT NOT NULL,
        collection TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        retry_after TEXT,
        last_error TEXT,
        is_creation INTEGER NOT NULL DEFAULT 0,
        creation_operation_id TEXT
      )
    ''');
    final columns = await database.rawQuery('PRAGMA table_info($_table)');
    final names = columns.map((row) => row['name']).toSet();
    for (final definition in <String, String>{
      'attempts': 'INTEGER NOT NULL DEFAULT 0',
      'retry_after': 'TEXT',
      'last_error': 'TEXT',
      'is_creation': 'INTEGER NOT NULL DEFAULT 0',
      'creation_operation_id': 'TEXT',
    }.entries) {
      if (!names.contains(definition.key)) {
        await database.execute(
          'ALTER TABLE $_table ADD COLUMN '
          '${definition.key} ${definition.value}',
        );
      }
    }
    await database.execute(
      'CREATE INDEX IF NOT EXISTS bicount_outbox_user_sequence '
      'ON $_table(user_id, sequence)',
    );
    await ensureOfflineArchiveSchema(database);
    await database.transaction((tx) async {
      await tx.execute(
        'CREATE TABLE IF NOT EXISTS bicount_offline_migrations '
        '(name TEXT PRIMARY KEY)',
      );
      const migration = 'guard_existing_legacy_queue_v1';
      final applied = await tx.query(
        'bicount_offline_migrations',
        where: 'name = ?',
        whereArgs: [migration],
      );
      if (applied.isNotEmpty) return;
      final imported = await tx.rawQuery(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' "
        "AND name = 'bicount_legacy_import'",
      );
      if (imported.isNotEmpty) {
        // Old imports did not retain a per-operation origin. Conservatively
        // guard all existing intents rather than risk replaying a stale write.
        await tx.execute(
          'INSERT OR IGNORE INTO bicount_legacy_pending_guard '
          '(user_id, collection, record_id) '
          'SELECT user_id, collection, record_id FROM $_table',
        );
      }
      await tx.insert('bicount_offline_migrations', {'name': migration});
    });
  }

  /// The mutation must use [transaction], so failure rolls back both writes.
  Future<T> commit<T>(
    OfflineOperation operation,
    Future<T> Function(Transaction transaction) mutation,
  ) {
    if (operation.userId.isEmpty ||
        operation.recordId.isEmpty ||
        operation.collection.isEmpty ||
        operation.action.isEmpty) {
      throw ArgumentError('An offline operation requires an owner and target.');
    }
    return database.transaction((transaction) async {
      final previous = await transaction.query(
        _table,
        columns: ['is_creation', 'creation_operation_id'],
        where: 'user_id = ? AND collection = ? AND record_id = ?',
        whereArgs: [operation.userId, operation.collection, operation.recordId],
        limit: 1,
      );
      final result = await mutation(transaction);
      await transaction.rawInsert(
        'INSERT OR IGNORE INTO bicount_guarded_operation_archive '
        '(operation_id, user_id, collection, record_id, action, payload, created_at, is_creation, creation_operation_id) '
        'SELECT operation_id, user_id, collection, record_id, action, payload, created_at, is_creation, creation_operation_id '
        'FROM $_table WHERE user_id = ? AND collection = ? AND record_id = ? '
        'AND EXISTS (SELECT 1 FROM bicount_legacy_pending_guard g '
        'WHERE g.user_id = $_table.user_id AND g.collection = $_table.collection '
        'AND g.record_id = $_table.record_id)',
        [operation.userId, operation.collection, operation.recordId],
      );
      await transaction.delete(
        _table,
        where: 'user_id = ? AND collection = ? AND record_id = ?',
        whereArgs: [operation.userId, operation.collection, operation.recordId],
      );
      final data = operation.toDatabase();
      if (previous.isNotEmpty && previous.single['is_creation'] == 1) {
        data['is_creation'] = 1;
        data['creation_operation_id'] =
            previous.single['creation_operation_id'];
      } else if (previous.isNotEmpty) {
        // A new claim cannot turn an older unknown intent into a proven create.
        data['is_creation'] = 0;
        data['creation_operation_id'] = null;
      } else if (operation.isCreation) {
        data['creation_operation_id'] =
            operation.creationOperationId ?? operation.id;
      }
      await transaction.insert(_table, data);
      return result;
    });
  }

  Future<List<OfflineOperation>> pending(
    String userId, {
    int limit = 100,
    bool excludeUnresolvedLegacy = false,
  }) async {
    if (userId.isEmpty || limit <= 0) {
      throw ArgumentError('A user and a positive limit are required.');
    }
    final rows = await database.query(
      _table,
      where:
          'user_id = ? AND (retry_after IS NULL OR retry_after <= ?)'
          '${excludeUnresolvedLegacy ? ' AND NOT EXISTS ('
                    'SELECT 1 FROM bicount_legacy_pending_guard g '
                    'WHERE g.user_id = $_table.user_id '
                    'AND g.collection = $_table.collection '
                    'AND g.record_id = $_table.record_id) AND NOT EXISTS ('
                    'SELECT 1 FROM bicount_legacy_finance_candidates c '
                    'WHERE c.target_table = $_table.collection '
                    'AND c.target_id = $_table.record_id)' : ''}',
      whereArgs: [userId, DateTime.now().toUtc().toIso8601String()],
      orderBy: 'sequence ASC',
      limit: limit,
    );
    return rows.map(OfflineOperation.fromDatabase).toList(growable: false);
  }

  /// Only call after the server has acknowledged this exact operation.
  Future<void> acknowledge(String userId, String operationId) async {
    await database.delete(
      _table,
      where: 'user_id = ? AND operation_id = ?',
      whereArgs: [userId, operationId],
    );
  }

  Future<void> defer(
    String userId,
    String operationId,
    Object error, {
    int attempts = 1,
  }) async {
    final seconds = (1 << attempts.clamp(0, 10)) * 5;
    final retryAfter = DateTime.now().toUtc().add(Duration(seconds: seconds));
    await database.rawUpdate(
      'UPDATE $_table SET attempts = attempts + 1, retry_after = ?, '
      'last_error = ? WHERE user_id = ? AND operation_id = ?',
      [retryAfter.toIso8601String(), error.toString(), userId, operationId],
    );
  }
}
