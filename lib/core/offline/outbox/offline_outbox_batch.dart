part of 'offline_outbox.dart';

extension OfflineOutboxBatch on OfflineOutbox {
  Future<void> commitBatch(
    Iterable<OfflineOperation> operations,
    Future<void> Function(Transaction, OfflineOperation) mutation,
  ) => database.transaction((tx) async {
    for (final operation in operations) {
      await _commit(
        tx,
        operation,
        (transaction) => mutation(transaction, operation),
      );
    }
  });
}
