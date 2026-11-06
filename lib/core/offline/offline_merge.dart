import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'offline_codecs.g.dart';

/// Applies server rows without overwriting changes still waiting in the outbox.
class OfflineMerge {
  const OfflineMerge();

  Future<void> snapshot({
    required Database db,
    required OfflineCodec<dynamic> codec,
    required String userId,
    required List<Map<String, dynamic>> rows,
    required List<String> confirmedDeletes,
  }) async {
    await db.transaction((tx) async {
      final protectedIds = await _pendingIds(tx, userId, codec.table);
      for (final row in rows) {
        final id = row[codec.key]?.toString();
        if (id == null || id.isEmpty || protectedIds.contains(id)) continue;
        await _writeRemote(tx, codec, row, id);
      }
      for (final id in confirmedDeletes) {
        if (protectedIds.contains(id)) continue;
        final removed = await tx.query(
          codec.localTable,
          where: '"${codec.localKey}" = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (removed.isNotEmpty) {
          await tx.insert(
            'bicount_removed_record_archive',
            {
              'table_name': codec.localTable,
              'record_id': id,
              'payload': jsonEncode(removed.single),
              'removed_at': DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          await tx.delete(
            codec.localTable,
            where: '"${codec.localKey}" = ?',
            whereArgs: [id],
          );
        }
      }
    });
  }

  Future<bool> event({
    required Database db,
    required OfflineCodec<dynamic> codec,
    required String userId,
    required String id,
    Map<String, dynamic>? row,
  }) async {
    return db.transaction((tx) async {
      final protectedIds = await _pendingIds(
        tx,
        userId,
        codec.table,
        recordId: id,
      );
      if (protectedIds.contains(id)) return false;
      if (row == null) {
        final removed = await tx.query(
          codec.localTable,
          where: '"${codec.localKey}" = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (removed.isNotEmpty) {
          await tx.insert(
            'bicount_removed_record_archive',
            {
              'table_name': codec.localTable,
              'record_id': id,
              'payload': jsonEncode(removed.single),
              'removed_at': DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await tx.delete(
          codec.localTable,
          where: '"${codec.localKey}" = ?',
          whereArgs: [id],
        );
      } else {
        await _writeRemote(tx, codec, row, id);
      }
      return true;
    });
  }

  Future<Set<String>> _pendingIds(
    DatabaseExecutor tx,
    String userId,
    String table, {
    String? recordId,
  }) async {
    final rows = await tx.query(
      'bicount_sync_outbox',
      columns: ['record_id'],
      where: recordId == null
          ? 'user_id = ? AND collection = ?'
          : 'user_id = ? AND collection = ? AND record_id = ?',
      whereArgs: recordId == null ? [userId, table] : [userId, table, recordId],
    );
    return rows.map((row) => row['record_id'].toString()).toSet();
  }

  Future<void> _writeRemote(
    DatabaseExecutor tx,
    OfflineCodec<dynamic> codec,
    Map<String, dynamic> row,
    String id,
  ) async {
    final serialized = codec.encodeLocal(codec.decodeRemote(row));
    final remoteColumns = codec.columns.keys
        .map((field) => codec.localColumns[field])
        .toSet();
    serialized.removeWhere((column, _) => !remoteColumns.contains(column));
    final updated = await tx.update(
      codec.localTable,
      serialized,
      where: '"${codec.localKey}" = ?',
      whereArgs: [id],
    );
    if (updated == 0) await tx.insert(codec.localTable, serialized);
  }
}
