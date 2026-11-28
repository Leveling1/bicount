part of 'offline_outbox.dart';

extension OfflineOutboxBatch on OfflineOutbox {
  Future<void> commitBatch(
    Iterable<OfflineOperation> operations,
    Future<void> Function(Transaction, OfflineOperation) mutation,
  ) => database.transaction(
    (tx) => commitBatchInTransaction(tx, operations, mutation),
  );

  Future<void> commitBatchInTransaction(
    Transaction tx,
    Iterable<OfflineOperation> operations,
    Future<void> Function(Transaction, OfflineOperation) mutation,
  ) async {
    for (final operation in operations) {
      await _commit(
        tx,
        operation,
        (transaction) => mutation(transaction, operation),
      );
    }
  }

  Future<bool> hasEarlierRelatedOperation(
    OfflineOperation operation,
    String relationKey,
  ) async {
    final rows = await database.query(
      OfflineOutbox._table,
      where:
          'user_id = ? AND collection = ? AND sequence < '
          '(SELECT sequence FROM ${OfflineOutbox._table} WHERE operation_id = ?)',
      whereArgs: [operation.userId, operation.collection, operation.id],
    );
    return rows
        .map(OfflineOperation.fromDatabase)
        .any(
          (earlier) =>
              earlier.payload[relationKey] == operation.payload[relationKey],
        );
  }
}
