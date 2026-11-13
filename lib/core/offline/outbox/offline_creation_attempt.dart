import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'offline_operation.dart';

/// Preserve the exact payload before a future creation request is sent.
/// A stale or unproven intent must never be sent by a creation protocol.
Future<bool> recordCreationAttempt(Database db, OfflineOperation operation) {
  if (!operation.isCreation ||
      operation.creationOperationId == null ||
      operation.action != 'upsert') {
    return Future.value(false);
  }
  return db.transaction((tx) async {
    final payload = jsonEncode(operation.payload);
    final current = await tx.query(
      'bicount_sync_outbox',
      columns: ['operation_id', 'payload'],
      where:
          'user_id = ? AND collection = ? AND record_id = ? '
          'AND operation_id = ? AND is_creation = 1 AND creation_operation_id = ?',
      whereArgs: [
        operation.userId,
        operation.collection,
        operation.recordId,
        operation.id,
        operation.creationOperationId,
      ],
      limit: 1,
    );
    if (current.isEmpty || current.single['payload'] != payload) return false;
    final previous = await tx.query(
      'bicount_creation_attempts',
      columns: ['creation_operation_id', 'collection', 'record_id', 'payload'],
      where: 'user_id = ? AND operation_id = ?',
      whereArgs: [operation.userId, operation.id],
      limit: 1,
    );
    if (previous.isNotEmpty) {
      final recorded = previous.single;
      return recorded['creation_operation_id'] ==
              operation.creationOperationId &&
          recorded['collection'] == operation.collection &&
          recorded['record_id'] == operation.recordId &&
          recorded['payload'] == payload;
    }
    await tx.insert('bicount_creation_attempts', {
      'user_id': operation.userId,
      'creation_operation_id': operation.creationOperationId,
      'operation_id': operation.id,
      'collection': operation.collection,
      'record_id': operation.recordId,
      'payload': payload,
      'operation_created_at': operation.createdAt.toIso8601String(),
      'attempted_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return true;
  });
}

/// Reserves the first send. Any earlier attempt is ambiguous without a server
/// receipt, even if a later local edit now has a different operation ID.
Future<bool> reserveFirstCreationSend(
  Database db,
  OfflineOperation operation, {
  required int journalSequence,
  required int journalGeneration,
}) {
  if (journalSequence < 0 || journalGeneration <= 0) {
    throw ArgumentError('Invalid creation journal marker.');
  }
  if (!operation.isCreation ||
      operation.action != 'upsert' ||
      operation.creationOperationId == null) {
    return Future.value(false);
  }
  return db.transaction((tx) async {
    final payload = jsonEncode(operation.payload);
    final current = await tx.query(
      'bicount_sync_outbox',
      columns: ['payload'],
      where:
          'user_id = ? AND collection = ? AND record_id = ? '
          'AND operation_id = ? AND is_creation = 1 AND creation_operation_id = ?',
      whereArgs: [
        operation.userId,
        operation.collection,
        operation.recordId,
        operation.id,
        operation.creationOperationId,
      ],
      limit: 1,
    );
    if (current.isEmpty || current.single['payload'] != payload) return false;
    final previous = await tx.query(
      'bicount_creation_attempts',
      columns: ['operation_id'],
      where: 'user_id = ? AND creation_operation_id = ?',
      whereArgs: [operation.userId, operation.creationOperationId],
      limit: 1,
    );
    if (previous.isNotEmpty) return false;
    await tx.insert('bicount_creation_attempts', {
      'user_id': operation.userId,
      'creation_operation_id': operation.creationOperationId,
      'operation_id': operation.id,
      'collection': operation.collection,
      'record_id': operation.recordId,
      'payload': payload,
      'operation_created_at': operation.createdAt.toIso8601String(),
      'attempted_at': DateTime.now().toUtc().toIso8601String(),
      'journal_sequence': journalSequence,
      'journal_generation': journalGeneration,
      'receipt_protocol': 1,
    });
    return true;
  });
}
