import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/supabaseService.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl();

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    CRUD crud = CRUD(table: 'transaction');
    try {
      crud.create(transaction);
    } catch (e) {
      throw UnknownFailure();
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() {
    throw UnimplementedError();
  }
}
