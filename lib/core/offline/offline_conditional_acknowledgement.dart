import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'outbox/offline_operation.dart';

/// Records the accepted server state and acknowledges only the exact intent.
/// A newer local edit is retained and will compare against this server state.
Future<void> acknowledgeConditionalMutation({
  required Database db,
  required OfflineOperation operation,
  required Map<String, dynamic>? remoteRow,
  required int journalSequence,
  required int journalGeneration,
}) async {
  if (journalSequence < 0 || journalGeneration <= 0) {
    throw ArgumentError('Invalid accepted journal marker.');
  }
  if (operation.action == 'upsert' && remoteRow == null) {
    throw StateError('An accepted update requires the returned server row.');
  }
  if (operation.action != 'upsert' && operation.action != 'delete') {
    throw ArgumentError('Unsupported conditional acknowledgement.');
  }
  await db.transaction((tx) async {
    await tx.insert('bicount_remote_baseline', {
      'user_id': operation.userId,
      'collection': operation.collection,
      'record_id': operation.recordId,
      'remote_payload': remoteRow == null ? null : jsonEncode(remoteRow),
      'journal_sequence': journalSequence,
      'journal_generation': journalGeneration,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await tx.delete(
      'bicount_sync_outbox',
      where: 'user_id = ? AND operation_id = ?',
      whereArgs: [operation.userId, operation.id],
    );
  });
}
