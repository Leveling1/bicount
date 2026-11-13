import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_codecs.g.dart';
import 'offline_payload_match.dart';
import 'offline_remote_winner_merge.dart';
import 'outbox/offline_operation.dart';

/// A baseline-less update may be retired only if every intended field is
/// already present on a row visible under RLS. This never writes to Supabase.
Future<bool> acknowledgeIdenticalRemote({
  required Database db,
  required SupabaseClient client,
  required OfflineOperation operation,
  required String? Function() currentUserId,
  required void Function(Type) notify,
}) async {
  if (operation.action != 'upsert' || operation.isCreation) return false;
  void checkUser() {
    if (currentUserId() != operation.userId) {
      throw StateError('Account changed during reconciliation.');
    }
  }

  checkUser();
  final codec = allOfflineCodecs.firstWhere(
    (entry) => entry.table == operation.collection,
  );
  final status = await client
      .rpc('bicount_sync_status')
      .timeout(const Duration(seconds: 8));
  checkUser();
  if (status is! Map ||
      status['enabled'] != true ||
      status['latest_sequence'] is! num ||
      status['generation'] is! num) {
    return false;
  }
  final sequence = (status['latest_sequence'] as num).toInt();
  final generation = (status['generation'] as num).toInt();
  if (sequence < 0 || generation <= 0) return false;
  final row = await client
      .from(codec.table)
      .select()
      .eq(codec.key, operation.recordId)
      .maybeSingle()
      .timeout(const Duration(seconds: 8));
  checkUser();
  if (row == null ||
      row[codec.key]?.toString() != operation.recordId ||
      !remoteContainsSentPayload(operation.payload, row)) {
    return false;
  }
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
