import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(CreateTransactionRequestEntity transaction);
  Future<void> updateTransaction(
    TransactionEntity previousTransaction,
    CreateTransactionRequestEntity transaction,
  );
}
