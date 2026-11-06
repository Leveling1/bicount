import 'package:sqflite_common/sqlite_api.dart';

import 'offline_operation.dart';

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
        last_error TEXT
      )
    ''');
    final columns = await database.rawQuery('PRAGMA table_info($_table)');
    final names = columns.map((row) => row['name']).toSet();
    for (final definition in <String, String>{
      'attempts': 'INTEGER NOT NULL DEFAULT 0',
      'retry_after': 'TEXT',
      'last_error': 'TEXT',
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
      final result = await mutation(transaction);
      await transaction.delete(
        _table,
        where: 'user_id = ? AND collection = ? AND record_id = ?',
        whereArgs: [operation.userId, operation.collection, operation.recordId],
      );
      await transaction.insert(_table, operation.toDatabase());
      return result;
    });
  }

  Future<List<OfflineOperation>> pending(
    String userId, {
    int limit = 100,
  }) async {
    if (userId.isEmpty || limit <= 0) {
      throw ArgumentError('A user and a positive limit are required.');
    }
    final rows = await database.query(
      _table,
      where: 'user_id = ? AND (retry_after IS NULL OR retry_after <= ?)',
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
