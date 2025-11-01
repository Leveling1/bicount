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

  @override
  Future<List<UserEntity>> getLinkedUsers() async {
    final crud = CRUD(table: 'users');
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final userData = await crud.readRowByID(authUser.id);
      final currentUser = UserEntity.fromData(userData);

      List<UserEntity> userList = (await linkedUsers("${currentUser.sid}")).cast<UserEntity>();

      return userList;
    } catch (e) {
      throw UnknownFailure();
    }
  }
}
