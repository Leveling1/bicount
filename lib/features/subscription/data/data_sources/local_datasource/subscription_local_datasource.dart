import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';

abstract class SubscriptionLocalDataSource {
  Future<Either<Failure, void>> addSubscription(SubscriptionEntity subscription);
  Future<Either<Failure, void>> unsubscribe(SubscriptionModel subscription);
}
