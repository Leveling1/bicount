import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

/// A guarded upsert can be acknowledged only when its entire payload already
/// exists on the same server row. No network write is made by this function.
Future<void> acknowledgeIdenticalLegacyUpserts({
  required Database db,
  required String userId,
  required String table,
  required String key,
  required List<Map<String, dynamic>> remoteRows,
}) async {
  final rowsById = <String, Map<String, dynamic>>{
    for (final row in remoteRows)
      if (row[key] != null) row[key].toString(): row,
  };
  await db.transaction((tx) async {
    final guarded = await tx.rawQuery(
      'SELECT o.* FROM bicount_sync_outbox o '
      'JOIN bicount_legacy_pending_guard g ON '
      'g.user_id = o.user_id AND g.collection = o.collection '
      'AND g.record_id = o.record_id '
      "WHERE o.user_id = ? AND o.collection = ? AND o.action = 'upsert'",
      [userId, table],
    );
    for (final operation in guarded) {
      final id = operation['record_id'] as String;
      final remote = rowsById[id];
      if (remote == null) continue;
      final decoded = jsonDecode(operation['payload'] as String);
      if (decoded is! Map || decoded.isEmpty) continue;
      if (!decoded.entries.every(
        (entry) =>
            entry.key is String &&
            remote.containsKey(entry.key) &&
            _sameValue(entry.value, remote[entry.key]),
      )) {
        continue;
      }
      await tx.insert(
        'bicount_guarded_operation_archive',
        {
          'operation_id': operation['operation_id'],
          'user_id': userId,
          'collection': table,
          'record_id': id,
          'action': operation['action'],
          'payload': operation['payload'],
          'created_at': operation['created_at'],
          'is_creation': operation['is_creation'] ?? 0,
          'creation_operation_id': operation['creation_operation_id'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      final removed = await tx.delete(
        'bicount_sync_outbox',
        where: 'user_id = ? AND operation_id = ?',
        whereArgs: [userId, operation['operation_id']],
      );
      if (removed == 1) {
        await tx.delete(
          'bicount_legacy_pending_guard',
          where: 'user_id = ? AND collection = ? AND record_id = ?',
          whereArgs: [userId, table, id],
        );
      }
    }
  });
}

bool _sameValue(Object? left, Object? right) {
  if (left is Map && right is Map) {
    return left.length == right.length &&
        left.entries.every(
          (entry) =>
              right.containsKey(entry.key) &&
              _sameValue(entry.value, right[entry.key]),
        );
  }
  if (left is List && right is List) {
    return left.length == right.length &&
        List.generate(
          left.length,
          (index) => index,
        ).every((index) => _sameValue(left[index], right[index]));
  }
  return left == right;
}
