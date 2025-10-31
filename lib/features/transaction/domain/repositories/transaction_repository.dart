import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';

import '../../../authentification/domain/entities/user.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(TransactionEntity transaction);

  Future<List<TransactionEntity>> getAllTransactions();

  Future<List<UserEntity>> getLinkedUsers();
}
