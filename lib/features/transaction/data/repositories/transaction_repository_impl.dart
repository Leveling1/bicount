import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/errors/failure.dart';
import '../../../../core/services/get_linked_users.dart';
import '../../../../core/services/supabaseService.dart';
import '../../../authentification/domain/entities/user.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction.model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl();

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    CRUD crud = CRUD(table: 'transaction');
    try {
      crud.create(transaction);
    } catch (e) {
      throw UnknownFailure();
    }
  }
}
