import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> getAllTransactions();
}
