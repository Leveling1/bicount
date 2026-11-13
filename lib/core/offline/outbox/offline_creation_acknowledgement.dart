import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'offline_operation.dart';

/// Finalizes a verified server creation without discarding a later local edit.
/// The caller must authenticate and validate the server receipt beforehand.
Future<bool> acknowledgeOfflineCreation({
  required Database db,
  required OfflineOperation sent,
  required String keyColumn,
  required Map<String, dynamic> remoteRow,
  required int journalSequence,
  required int journalGeneration,
  required String? Function() currentUserId,
}) {
  if (!sent.isCreation ||
      sent.action != 'upsert' ||
      sent.creationOperationId == null ||
      remoteRow[keyColumn]?.toString() != sent.recordId ||
      journalSequence < 0 ||
      journalGeneration <= 0) {
    throw ArgumentError('Invalid creation acknowledgement.');
  }
  void checkUser() {
    if (currentUserId() != sent.userId) {
      throw StateError('Account changed during creation acknowledgement.');
    }
  }

  checkUser();
  return db.transaction((tx) async {
    checkUser();
    final attempts = await tx.query(
      'bicount_creation_attempts',
      where:
          'user_id = ? AND operation_id = ? AND creation_operation_id = ? '
          'AND collection = ? AND record_id = ?',
      whereArgs: [
        sent.userId,
        sent.id,
        sent.creationOperationId,
        sent.collection,
        sent.recordId,
      ],
      limit: 1,
    );
    if (attempts.isEmpty ||
        attempts.single['payload'] != jsonEncode(sent.payload) ||
        attempts.single['journal_sequence'] != journalSequence ||
        attempts.single['journal_generation'] != journalGeneration) {
      return false;
    }
    final current = await tx.query(
      'bicount_sync_outbox',
      columns: ['operation_id'],
      where:
          'user_id = ? AND collection = ? AND record_id = ? '
          'AND is_creation = 1 AND creation_operation_id = ?',
      whereArgs: [
        sent.userId,
        sent.collection,
        sent.recordId,
        sent.creationOperationId,
      ],
      limit: 1,
    );
    if (current.isEmpty) return false;
    await tx.insert('bicount_remote_baseline', {
      'user_id': sent.userId,
      'collection': sent.collection,
      'record_id': sent.recordId,
      'remote_payload': jsonEncode(remoteRow),
      'journal_sequence': journalSequence,
      'journal_generation': journalGeneration,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    if (current.single['operation_id'] == sent.id) {
      await tx.delete(
        'bicount_sync_outbox',
        where: 'user_id = ? AND operation_id = ?',
        whereArgs: [sent.userId, sent.id],
      );
    } else {
      await tx.update(
        'bicount_sync_outbox',
        {'is_creation': 0, 'creation_operation_id': null},
        where: 'user_id = ? AND operation_id = ? AND creation_operation_id = ?',
        whereArgs: [
          sent.userId,
          current.single['operation_id'],
          sent.creationOperationId,
        ],
      );
    }
    checkUser();
    return true;
  });
}
