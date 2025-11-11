
abstract class TransactionRepository {
  Future<void> createTransaction(Map<String, dynamic> transaction);
}
