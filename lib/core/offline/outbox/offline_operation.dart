import 'dart:convert';

import 'package:uuid/uuid.dart';

/// A durable intent to synchronize one local change with the server.
class OfflineOperation {
  OfflineOperation({
    String? id,
    required this.userId,
    required this.collection,
    required this.recordId,
    required this.action,
    required this.payload,
    DateTime? createdAt,
    this.attempts = 0,
    this.isCreation = false,
    this.creationOperationId,
    this.editedEarliest,
    this.editedLatest,
  }) : id = id ?? const Uuid().v4(),
       createdAt = (createdAt ?? DateTime.now()).toUtc();

  final String id;
  final String userId;
  final String collection;
  final String recordId;
  final String action;
  final Map<String, Object?> payload;
  final DateTime createdAt;
  final int attempts;
  final bool isCreation;

  /// Stable origin of a locally created row; null means provenance is unknown.
  final String? creationOperationId;
  final DateTime? editedEarliest;
  final DateTime? editedLatest;

  Map<String, Object?> toDatabase() => {
    'operation_id': id,
    'user_id': userId,
    'collection': collection,
    'record_id': recordId,
    'action': action,
    'payload': jsonEncode(payload),
    'created_at': createdAt.toIso8601String(),
    'is_creation': isCreation ? 1 : 0,
    'creation_operation_id': creationOperationId,
    if (editedEarliest != null)
      'edited_earliest': editedEarliest!.toUtc().toIso8601String(),
    if (editedLatest != null)
      'edited_latest': editedLatest!.toUtc().toIso8601String(),
  };

  factory OfflineOperation.fromDatabase(Map<String, Object?> row) {
    return OfflineOperation(
      id: row['operation_id'] as String,
      userId: row['user_id'] as String,
      collection: row['collection'] as String,
      recordId: row['record_id'] as String,
      action: row['action'] as String,
      payload: (jsonDecode(row['payload'] as String) as Map)
          .cast<String, Object?>(),
      createdAt: DateTime.parse(row['created_at'] as String),
      attempts: (row['attempts'] as int?) ?? 0,
      isCreation: (row['is_creation'] as int? ?? 0) == 1,
      creationOperationId: row['creation_operation_id'] as String?,
      editedEarliest: row['edited_earliest'] == null
          ? null
          : DateTime.parse(row['edited_earliest'] as String).toUtc(),
      editedLatest: row['edited_latest'] == null
          ? null
          : DateTime.parse(row['edited_latest'] as String).toUtc(),
    );
  }
}
