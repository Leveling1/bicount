import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';

abstract class TransactionLocalDataSource {
  Future<Either<Failure, FriendsModel>> createANewFriend(FriendsModel friend);
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
  });
  Future<Either<Failure, void>> addSubscription(
    SubscriptionEntity subscription,
  );
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
  });
  Future<Either<Failure, void>> unsubscribe(SubscriptionModel subscription);
}
