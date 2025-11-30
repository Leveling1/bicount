import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../brick/repository.dart';
import '../../models/transaction.model.dart';

class LocalTransactionDataSourceImpl implements TransactionLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
    FriendsModel friend,
  ) async {
    final id = Uuid().v4();
    try {
      final FriendsModel friendAdd = FriendsModel(
        uid: id,
        sid: id,
        fid: uid,
        username: friend.username,
        email: friend.email,
        image: Constants.memojiDefault,
        give: 0.0,
        receive: 0.0,
      );

      await Repository().upsert<FriendsModel>(friendAdd);
      return Right(friendAdd);
    } catch (e) {
      return Left(
        MessageFailure(
          message: 'An error occurred while saving your new friend.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
    Map<String, dynamic> transaction,
    String gtid,
    String senderId,
    String beneficiaryId,
    String image,
  ) async {
    try {
      final transactionModel = TransactionModel(
        uid: uid,
        gtid: gtid,
        name: transaction['name'],
        type: transaction['type'],
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        date: transaction['date'],
        note: transaction['note'],
        amount: transaction['amount'],
        currency: transaction['currency'],
        image: image,
        frequency: 'fixe',
        createdAt: DateTime.now().toIso8601String(),
        category: Constants.personnal,
      );
      await Repository().upsert<TransactionModel>(transactionModel);
      return Right(null);
    } catch (e) {
      return Left(
        MessageFailure(message: 'The transaction could not be saved.'),
      );
    }
  }
}
