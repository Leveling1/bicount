import 'package:sqflite_common/sqlite_api.dart';

import 'offline_conflict_archive.dart';
import 'outbox/offline_operation.dart';

/// Atomically archives a superseded intent and applies the selected server row.
/// The caller must establish the winner and validate the remote row first.
/// Returns false if a newer local operation replaced the one being resolved.
Future<bool> applyRemoteConflictWinner({
  required Database db,
  required OfflineOperation operation,
  required Map<String, dynamic>? remoteRow,
  required Future<void> Function(Transaction tx) applyRemote,
}) {
  return db.transaction((tx) async {
    final current = await tx.query(
      'bicount_sync_outbox',
      columns: ['operation_id'],
      where:
          'user_id = ? AND collection = ? AND record_id = ? AND operation_id = ?',
      whereArgs: [
        operation.userId,
        operation.collection,
        operation.recordId,
        operation.id,
      ],
      limit: 1,
    );
    if (current.isEmpty) return false;
    await archiveConflictInTransaction(
      tx: tx,
      operation: operation,
      reason: 'remote_winner',
      remoteRow: remoteRow,
    );
    final removed = await tx.delete(
      'bicount_sync_outbox',
      where: 'user_id = ? AND operation_id = ?',
      whereArgs: [operation.userId, operation.id],
    );
    if (removed != 1) {
      throw StateError('Conflict operation changed during resolution.');
    }
    // Removing the exact intent inside this uncommitted transaction allows
    // OfflineMerge to apply the remote row without bypassing its guards.
    await applyRemote(tx);
    return true;
  });
}
