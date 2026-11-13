import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_codecs.g.dart';
import 'offline_payload_match.dart';
import 'outbox/offline_creation_acknowledgement.dart';
import 'outbox/offline_creation_attempt.dart';
import 'outbox/offline_operation.dart';

/// Preproduction-only receipt-backed creation; uncertain results stay queued.
Future<bool> deliverConditionalCreation({
  required Database db,
  required SupabaseClient client,
  required OfflineOperation operation,
  required String? Function() currentUserId,
}) async {
  void checkUser() {
    if (currentUserId() != operation.userId) {
      throw StateError('Account changed during creation delivery.');
    }
  }

  checkUser();
  final codec = allOfflineCodecs.firstWhere(
    (item) => item.table == operation.collection,
  );
  if (operation.payload[codec.key]?.toString() != operation.recordId) {
    throw StateError('Invalid creation identity.');
  }
  final creationId = operation.creationOperationId;
  if (!operation.isCreation || creationId == null) return false;
  Future<List<Map<String, Object?>>> attempts() => db.query(
    'bicount_creation_attempts',
    where:
        'user_id = ? AND creation_operation_id = ? AND collection = ? AND record_id = ?',
    whereArgs: [
      operation.userId,
      creationId,
      operation.collection,
      operation.recordId,
    ],
    limit: 2,
  );
  var saved = await attempts();
  if (saved.isEmpty) {
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
    if (!await reserveFirstCreationSend(
      db,
      operation,
      journalSequence: sequence,
      journalGeneration: generation,
    )) {
      return false;
    }
    saved = await attempts();
  }
  if (saved.length != 1) return false;
  final attempt = saved.single;
  if (attempt['receipt_protocol'] != 1) return false;
  final sequence = attempt['journal_sequence'];
  final generation = attempt['journal_generation'];
  if (sequence is! int ||
      generation is! int ||
      sequence < 0 ||
      generation <= 0) {
    return false;
  }
  final payload = (jsonDecode(attempt['payload'] as String) as Map)
      .cast<String, Object?>();
  if (payload[codec.key]?.toString() != operation.recordId) return false;
  final sent = OfflineOperation(
    id: attempt['operation_id'] as String,
    userId: operation.userId,
    collection: operation.collection,
    recordId: operation.recordId,
    action: 'upsert',
    payload: payload,
    isCreation: true,
    creationOperationId: creationId,
    createdAt: DateTime.parse(attempt['operation_created_at'] as String),
  );
  checkUser();
  final result = await client
      .rpc(
        'bicount_create_once',
        params: {
          'p_table': codec.table,
          'p_id': operation.recordId,
          'p_creation_id': creationId,
          'p_payload': payload,
        },
      )
      .timeout(const Duration(seconds: 8));
  checkUser();
  if (result is! Map ||
      (result['status'] != 'applied' &&
          result['status'] != 'already_applied')) {
    return false;
  }
  Map<String, dynamic>? row;
  if (result['status'] == 'applied' && result['row'] is Map) {
    row = Map<String, dynamic>.from(result['row'] as Map);
  } else if (result['status'] == 'already_applied') {
    final current = await client
        .from(codec.table)
        .select()
        .eq(codec.key, operation.recordId)
        .maybeSingle()
        .timeout(const Duration(seconds: 8));
    checkUser();
    if (current == null || !remoteContainsSentPayload(payload, current)) {
      return false;
    }
    row = current;
  }
  if (row == null || row[codec.key]?.toString() != operation.recordId) {
    return false;
  }
  return acknowledgeOfflineCreation(
    db: db,
    sent: sent,
    keyColumn: codec.key,
    remoteRow: row,
    journalSequence: sequence,
    journalGeneration: generation,
    currentUserId: currentUserId,
  );
}
