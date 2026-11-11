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
    int? observedSequence,
    int? observedGeneration,
  }) async {
    _validateMarker(observedSequence, observedGeneration);
    await db.transaction((tx) async {
      final protectedIds = await _pendingIds(tx, userId, codec.table);
      for (final row in rows) {
        final id = row[codec.key]?.toString();
        if (id == null || id.isEmpty || protectedIds.contains(id)) continue;
        await _writeRemote(
          tx,
          codec,
          row,
          id,
          userId,
          observedSequence,
          observedGeneration,
        );
      }
      for (final id in confirmedDeletes) {
        if (protectedIds.contains(id)) continue;
        await _rememberRemote(
          tx,
          userId,
          codec.table,
          id,
          null,
          observedSequence,
          observedGeneration,
        );
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
    int? observedSequence,
    int? observedGeneration,
  }) async {
    return db.transaction(
      (tx) => eventInTransaction(
        tx: tx,
        codec: codec,
        userId: userId,
        id: id,
        row: row,
        observedSequence: observedSequence,
        observedGeneration: observedGeneration,
      ),
    );
  }

  Future<bool> eventInTransaction({
    required DatabaseExecutor tx,
    required OfflineCodec<dynamic> codec,
    required String userId,
    required String id,
    Map<String, dynamic>? row,
    int? observedSequence,
    int? observedGeneration,
  }) async {
    _validateMarker(observedSequence, observedGeneration);
    final protectedIds = await _pendingIds(
      tx,
      userId,
      codec.table,
      recordId: id,
    );
    if (protectedIds.contains(id)) return false;
    if (row == null) {
      await _rememberRemote(
        tx,
        userId,
        codec.table,
        id,
        null,
        observedSequence,
        observedGeneration,
      );
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
      await _writeRemote(
        tx,
        codec,
        row,
        id,
        userId,
        observedSequence,
        observedGeneration,
      );
    }
    return true;
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
    final ids = rows.map((row) => row['record_id'].toString()).toSet();
    final candidateTable = await tx.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' "
      "AND name = 'bicount_legacy_finance_candidates'",
    );
    if (candidateTable.isNotEmpty) {
      final candidates = await tx.query(
        'bicount_legacy_finance_candidates',
        columns: ['target_id'],
        where: recordId == null
            ? 'target_table = ?'
            : 'target_table = ? AND target_id = ?',
        whereArgs: recordId == null ? [table] : [table, recordId],
      );
      ids.addAll(candidates.map((row) => row['target_id'].toString()));
    }
    return ids;
  }

  Future<void> _writeRemote(
    DatabaseExecutor tx,
    OfflineCodec<dynamic> codec,
    Map<String, dynamic> row,
    String id,
    String userId,
    int? observedSequence,
    int? observedGeneration,
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
    await _rememberRemote(
      tx,
      userId,
      codec.table,
      id,
      row,
      observedSequence,
      observedGeneration,
    );
  }

  Future<void> _rememberRemote(
    DatabaseExecutor tx,
    String userId,
    String table,
    String id,
    Map<String, dynamic>? row,
    int? observedSequence,
    int? observedGeneration,
  ) async {
    await tx.insert('bicount_remote_baseline', {
      'user_id': userId,
      'collection': table,
      'record_id': id,
      'remote_payload': row == null ? null : jsonEncode(row),
      'journal_sequence': observedSequence,
      'journal_generation': observedGeneration,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _validateMarker(int? sequence, int? generation) {
    if ((sequence == null) != (generation == null) ||
        (sequence != null && (sequence < 0 || generation! <= 0))) {
      throw ArgumentError('Invalid journal marker.');
    }
  }
}
