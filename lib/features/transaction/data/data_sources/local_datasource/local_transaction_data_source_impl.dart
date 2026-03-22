import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
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
    final id = const Uuid().v4();
    try {
      final friendAdd = FriendsModel(
        uid: null,
        sid: id,
        fid: uid,
        username: friend.username,
        email: friend.email,
        image: friend.image.isEmpty ? Constants.memojiDefault : friend.image,
        give: 0.0,
        receive: 0.0,
        relationType: FriendConst.friend,
      );

      await Repository().upsert<FriendsModel>(friendAdd);
      return Right(friendAdd);
    } catch (_) {
      return Left(
        MessageFailure(message: 'Unable to save this friend right now.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    required String title,
    required String date,
    required double amount,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
  }) async {
    try {
      var type = TransactionTypes.othersCode;
      if (senderId == uid) {
        type = TransactionTypes.expenseCode;
      } else if (beneficiaryId == uid) {
        type = TransactionTypes.incomeCode;
      }

      final transactionModel = TransactionModel(
        uid: uid,
        gtid: gtid,
        name: title,
        type: type,
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        date: date,
        note: note,
        amount: amount,
        currency: currency,
        image: image,
        frequency: Frequency.oneTime,
        createdAt: DateTime.now().toIso8601String(),
        category: Constants.personal,
      );

      await Repository().upsert<TransactionModel>(transactionModel);
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(message: 'The transaction could not be saved.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addSubscription(
    SubscriptionEntity subscription,
  ) async {
    try {
      final id = const Uuid().v4();
      final subscriptionAdd = SubscriptionModel(
        subscriptionId: id,
        sid: uid,
        title: subscription.title,
        amount: subscription.amount,
        currency: subscription.currency,
        frequency: subscription.frequency,
        startDate: subscription.startDate,
        nextBillingDate: subscription.nextBillingDate,
        notes: subscription.note,
        status: subscription.status,
        createdAt: subscription.createdAt,
      );

      await Repository().upsert<SubscriptionModel>(subscriptionAdd);
      return const Right(null);
    } catch (error) {
      return Left(
        MessageFailure(message: 'Unable to save this subscription right now.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribe(
    SubscriptionModel subscription,
  ) async {
    try {
      await Repository().upsert<SubscriptionModel>(subscription);
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(
          message: 'Unable to update this subscription right now.',
        ),
      );
    }
  }
}
