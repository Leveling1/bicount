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

  Map<String, Object?> toDatabase() => {
    'operation_id': id,
    'user_id': userId,
    'collection': collection,
    'record_id': recordId,
    'action': action,
    'payload': jsonEncode(payload),
    'created_at': createdAt.toIso8601String(),
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
    );
  }
}
