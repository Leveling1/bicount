import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'outbox/offline_operation.dart';

/// Preserve both versions and the baseline without deleting a pending intent.
Future<void> archiveConditionalConflict({
  required Database db,
  required OfflineOperation operation,
  required String reason,
  Map<String, dynamic>? remoteRow,
}) async {
  await db.transaction((tx) async {
    await archiveConflictInTransaction(
      tx: tx,
      operation: operation,
      reason: reason,
      remoteRow: remoteRow,
    );
  });
}

/// Allows a future conflict resolution and its archive to commit atomically.
Future<void> archiveConflictInTransaction({
  required Transaction tx,
  required OfflineOperation operation,
  required String reason,
  Map<String, dynamic>? remoteRow,
}) async {
  final baseline = await tx.query(
    'bicount_remote_baseline',
    columns: ['remote_payload'],
    where: 'user_id = ? AND collection = ? AND record_id = ?',
    whereArgs: [operation.userId, operation.collection, operation.recordId],
    limit: 1,
  );
  final baselinePayload = baseline.isEmpty
      ? null
      : baseline.single['remote_payload'];
  final remotePayload = remoteRow == null ? null : jsonEncode(remoteRow);
  final existing = await tx.query(
    'bicount_sync_conflict_archive',
    columns: ['conflict_id'],
    where:
        'user_id = ? AND operation_id = ? AND reason = ? '
        '${remotePayload == null ? 'AND remote_payload IS NULL ' : 'AND remote_payload = ? '}'
        '${baselinePayload == null ? 'AND baseline_payload IS NULL' : 'AND baseline_payload = ?'}',
    whereArgs: [
      operation.userId,
      operation.id,
      reason,
      if (remotePayload != null) remotePayload,
      if (baselinePayload != null) baselinePayload,
    ],
    limit: 1,
  );
  if (existing.isNotEmpty) return;
  await tx.insert('bicount_sync_conflict_archive', {
    'operation_id': operation.id,
    'user_id': operation.userId,
    'collection': operation.collection,
    'record_id': operation.recordId,
    'action': operation.action,
    'local_payload': jsonEncode(operation.payload),
    'local_created_at': operation.createdAt.toIso8601String(),
    'is_creation': operation.isCreation ? 1 : 0,
    'creation_operation_id': operation.creationOperationId,
    'baseline_payload': baselinePayload,
    'remote_payload': remotePayload,
    'reason': reason,
    'recorded_at': DateTime.now().toUtc().toIso8601String(),
  });
}
