import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'outbox/offline_operation.dart';
import 'offline_codecs.g.dart';

enum ConditionalMutationResult { applied, conflict, unavailable }

class ConditionalMutationReply {
  const ConditionalMutationReply(
    this.result, {
    this.remoteRow,
    this.journalSequence,
    this.journalGeneration,
  });
  final ConditionalMutationResult result;
  final Map<String, dynamic>? remoteRow;
  final int? journalSequence;
  final int? journalGeneration;
}

/// Experimental primitive; callers must retain the outbox entry unless applied.
/// Creations and rows with no known baseline intentionally remain unavailable.
Future<ConditionalMutationReply> sendConditionalMutation({
  required Database db,
  required SupabaseClient client,
  required OfflineOperation operation,
  required String? Function() currentUserId,
}) async {
  if (operation.action != 'upsert' && operation.action != 'delete') {
    throw ArgumentError('Only model updates and deletes are supported.');
  }
  if (currentUserId() != operation.userId) {
    throw StateError('Account changed before conditional mutation.');
  }
  final rows = await db.query(
    'bicount_remote_baseline',
    columns: ['remote_payload', 'journal_sequence', 'journal_generation'],
    where: 'user_id = ? AND collection = ? AND record_id = ?',
    whereArgs: [operation.userId, operation.collection, operation.recordId],
    limit: 1,
  );
  if (rows.isEmpty ||
      rows.single['remote_payload'] == null ||
      rows.single['journal_sequence'] == null ||
      rows.single['journal_generation'] == null) {
    return const ConditionalMutationReply(
      ConditionalMutationResult.unavailable,
    );
  }
  final baseline = jsonDecode(rows.single['remote_payload'] as String);
  final sequence = (rows.single['journal_sequence'] as num).toInt();
  final generation = (rows.single['journal_generation'] as num).toInt();
  if (sequence < 0 || generation <= 0) {
    throw StateError('Invalid baseline journal marker.');
  }
  if (baseline is! Map<String, dynamic>) {
    throw StateError('Invalid remote baseline.');
  }
  if (currentUserId() != operation.userId) {
    throw StateError('Account changed before conditional mutation.');
  }
  final response = await client
      .rpc(
        'bicount_conditional_journal_guard',
        params: {
          'p_table': operation.collection,
          'p_id': operation.recordId,
          'p_action': operation.action == 'upsert' ? 'update' : 'delete',
          'p_expected': baseline,
          'p_seen_sequence': sequence,
          'p_generation': generation,
          'p_patch': operation.action == 'upsert' ? operation.payload : null,
        },
      )
      .timeout(const Duration(seconds: 8));
  if (currentUserId() != operation.userId) {
    throw StateError('Account changed during conditional mutation.');
  }
  if (response is! Map) throw StateError('Invalid conditional mutation reply.');
  switch (response['status']) {
    case 'applied':
    case 'already_applied':
      final row = response['row'];
      final codec = allOfflineCodecs.firstWhere(
        (c) => c.table == operation.collection,
      );
      if (row is! Map || row[codec.key]?.toString() != operation.recordId) {
        throw StateError('Conditional mutation returned an invalid row.');
      }
      final responseSequence = response['journal_sequence'];
      final responseGeneration = response['journal_generation'];
      if (responseSequence is! num ||
          responseGeneration is! num ||
          responseSequence.toInt() < sequence ||
          responseGeneration.toInt() != generation) {
        throw StateError(
          'Conditional mutation returned an invalid journal marker.',
        );
      }
      return ConditionalMutationReply(
        ConditionalMutationResult.applied,
        remoteRow: operation.action == 'delete'
            ? null
            : Map<String, dynamic>.from(row),
        journalSequence: responseSequence.toInt(),
        journalGeneration: responseGeneration.toInt(),
      );
    case 'conflict':
      final row = response['row'];
      if (row == null) {
        return const ConditionalMutationReply(
          ConditionalMutationResult.conflict,
        );
      }
      final codec = allOfflineCodecs.firstWhere(
        (c) => c.table == operation.collection,
      );
      if (row is! Map || row[codec.key]?.toString() != operation.recordId) {
        throw StateError('Conditional conflict returned an invalid row.');
      }
      return ConditionalMutationReply(
        ConditionalMutationResult.conflict,
        remoteRow: Map<String, dynamic>.from(row),
      );
    case 'not_applied':
      return const ConditionalMutationReply(
        ConditionalMutationResult.unavailable,
      );
    default:
      throw StateError('Unknown conditional mutation reply.');
  }
}
