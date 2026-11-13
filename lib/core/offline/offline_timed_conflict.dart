import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_codecs.g.dart';
import 'offline_conditional_acknowledgement.dart';
import 'offline_conflict_archive.dart';
import 'offline_conflict_order.dart';
import 'offline_remote_winner_merge.dart';
import 'outbox/offline_operation.dart';

/// Returns false when chronology or the server state cannot be established.
Future<bool> resolveTimedConflict({
  required Database db,
  required SupabaseClient client,
  required OfflineOperation operation,
  required String? Function() currentUserId,
  required void Function(Type) notify,
}) async {
  final earliest = operation.editedEarliest;
  final latest = operation.editedLatest;
  if (earliest == null || latest == null || earliest.isAfter(latest)) {
    return false;
  }
  void checkUser() {
    if (currentUserId() != operation.userId) {
      throw StateError('Account changed during conflict resolution.');
    }
  }

  checkUser();
  final baseline = await db.query(
    'bicount_remote_baseline',
    columns: ['journal_sequence', 'journal_generation'],
    where: 'user_id = ? AND collection = ? AND record_id = ?',
    whereArgs: [operation.userId, operation.collection, operation.recordId],
    limit: 1,
  );
  if (baseline.isEmpty ||
      baseline.single['journal_sequence'] is! int ||
      baseline.single['journal_generation'] is! int) {
    return false;
  }
  final codec = allOfflineCodecs.firstWhere(
    (item) => item.table == operation.collection,
  );
  checkUser();
  final params = <String, Object?>{
    'p_table': operation.collection,
    'p_id': operation.recordId,
    'p_seen_sequence': baseline.single['journal_sequence'],
    'p_generation': baseline.single['journal_generation'],
  };
  var result = await client
      .rpc('bicount_observe_conflict', params: params)
      .timeout(const Duration(seconds: 8));
  checkUser();
  if (result is Map && result['status'] == 'unavailable') {
    result = await client
        .rpc('bicount_observe_deleted_conflict', params: params)
        .timeout(const Duration(seconds: 8));
    checkUser();
  }
  if (result is! Map ||
      (result['status'] != 'observed' && result['status'] != 'deleted') ||
      (result['status'] == 'observed' && result['row'] is! Map) ||
      result['journal_sequence'] is! num ||
      result['journal_generation'] is! num ||
      result['remote_time'] is! String ||
      result['server_time'] is! String) {
    return false;
  }
  final row = result['status'] == 'deleted'
      ? null
      : Map<String, dynamic>.from(result['row'] as Map);
  final remoteTime = DateTime.tryParse(
    result['remote_time'] as String,
  )?.toUtc();
  final serverTime = DateTime.tryParse(
    result['server_time'] as String,
  )?.toUtc();
  final sequence = (result['journal_sequence'] as num).toInt();
  final generation = (result['journal_generation'] as num).toInt();
  if ((row != null && row[codec.key]?.toString() != operation.recordId) ||
      remoteTime == null ||
      serverTime == null ||
      earliest.isAfter(serverTime.add(const Duration(seconds: 10))) ||
      remoteTime.isAfter(serverTime.add(const Duration(seconds: 2))) ||
      sequence < 0 ||
      generation <= 0) {
    return false;
  }
  if (row == null && operation.action == 'delete') {
    final applied = await mergeRemoteConflictWinner(
      db: db,
      operation: operation,
      codec: codec,
      remoteRow: null,
      journalSequence: sequence,
      journalGeneration: generation,
      currentUserId: currentUserId,
    );
    if (applied) notify(codec.modelType);
    return applied;
  }
  final midpoint = earliest.add(latest.difference(earliest) ~/ 2);
  final order = compareConflictTimes(
    local: ConflictTimeEstimate(midpoint, latest.difference(earliest) ~/ 2),
    remote: ConflictTimeEstimate(remoteTime, const Duration(seconds: 2)),
  );
  if (order == ConflictOrder.uncertain) return false;
  if (order == ConflictOrder.remoteLater) {
    final applied = await mergeRemoteConflictWinner(
      db: db,
      operation: operation,
      codec: codec,
      remoteRow: row,
      journalSequence: sequence,
      journalGeneration: generation,
      currentUserId: currentUserId,
    );
    if (applied) notify(codec.modelType);
    return applied;
  }

  // Resurrection of a remotely deleted row needs its own guarded protocol.
  if (row == null) return false;

  // Retain the server version before any conditional overwrite.
  await archiveConditionalConflict(
    db: db,
    operation: operation,
    reason: 'local_winner',
    remoteRow: row,
  );
  checkUser();
  final answer = await client
      .rpc(
        'bicount_conditional_journal_guard',
        params: {
          'p_table': operation.collection,
          'p_id': operation.recordId,
          'p_action': operation.action == 'delete' ? 'delete' : 'update',
          'p_expected': row,
          'p_seen_sequence': sequence,
          'p_generation': generation,
          'p_patch': operation.action == 'upsert' ? operation.payload : null,
        },
      )
      .timeout(const Duration(seconds: 8));
  checkUser();
  if (answer is! Map ||
      (answer['status'] != 'applied' &&
          answer['status'] != 'already_applied') ||
      answer['journal_sequence'] is! num ||
      answer['journal_generation'] is! num ||
      answer['row'] is! Map) {
    return false;
  }
  final confirmed = Map<String, dynamic>.from(answer['row'] as Map);
  final newSequence = (answer['journal_sequence'] as num).toInt();
  final newGeneration = (answer['journal_generation'] as num).toInt();
  if (confirmed[codec.key]?.toString() != operation.recordId ||
      newSequence < sequence ||
      newGeneration != generation) {
    return false;
  }
  await acknowledgeConditionalMutation(
    db: db,
    operation: operation,
    remoteRow: operation.action == 'delete' ? null : confirmed,
    journalSequence: newSequence,
    journalGeneration: newGeneration,
  );
  return true;
}
