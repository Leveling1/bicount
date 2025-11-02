import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../brick/repository.dart';
import '../../../../authentification/data/models/user.model.dart';
import '../../../../authentification/data/models/user_links.model.dart';
import '../../models/transaction.model.dart';

class LocalTransactionDataSourceImpl implements TransactionLocalDataSource {

  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  @override
  Future<Either<Failure, UserModel>> createANewFriend(FriendsModel friend) async {
    final id = Uuid().v4();
    try {
      final UserModel friendAdd = UserModel(
        uid: id,
        sid: id,
        username: friend.username,
        email: friend.email,
        image: 'memoji_default',
        sales: 0.0,
        personalIncome: 0.0,
        companyIncome: 0.0,
        profit: 0.0,
        expenses: 0.0,
      );
      await Repository().upsert<UserModel>(friendAdd);
      return Right(friendAdd);
    } catch (e) {
      return Left(MessageFailure(message: 'An error occurred while saving your new friend.'));
    }
  }

  @override
  Future<Either<Failure, void>> createANewLink(UserModel friend) async {
    final lid = Uuid().v4();
    try {
      final createdNewLink = UserLinkModel(
          lid: lid,
          userAId: uid,
          userBId: friend.sid,
          linkType: 'friend',
          status: 'accepted'
      );
      await Repository().upsert<UserLinkModel>(createdNewLink);
      return Right(null);
    } catch (e) {
      return Left(MessageFailure(message: '(Link) An error occurred while saving your new friend.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
      Map<String, dynamic> transaction, String friendId) async {
    try {
      final transactionModel = TransactionModel(
          gtid: transaction['gtid'],
          name: transaction['name'],
          type: transaction['type'],
          beneficiaryId: friendId,
          senderId: transaction['senderId'],
          date: transaction['date'],
          note: transaction['note'],
          amount: transaction['amount'],
          currency: transaction['currency']
      );
      await Repository().upsert<TransactionModel>(transactionModel);
      return Right(null);
    } catch (e) {
      return Left(MessageFailure(message: 'The transaction could not be saved.'));
    }
  }
  
}