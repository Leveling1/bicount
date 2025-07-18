import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';

import '../../../../core/services/supabaseService.dart';

abstract class TransactionRepository {
  final TransactionModel transaction;
  CRUD crud = CRUD(table: 'transactions');

  TransactionRepository(this.transaction, this.crud);

  void addTransaction() {
    crud.create(transaction);
  }
}
