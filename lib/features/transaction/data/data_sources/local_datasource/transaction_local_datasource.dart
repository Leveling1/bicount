import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';

abstract class TransactionLocalDataSource {
  Future<Either<Failure, FriendsModel>> createANewFriend(FriendsModel friend);
  Future<Either<Failure, void>> saveTransaction(
    Map<String, dynamic> transaction,
    String gtid,
    String senderId,
    String beneficiaryId,
    String image,
  );
  Future<Either<Failure, void>> addSubscription(
    SubscriptionEntity subscription,
  );
  Future<Either<Failure, void>> unsubscribe(SubscriptionModel subscription);
}
