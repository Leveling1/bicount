import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<void> addSubscription(SubscriptionEntity subscription);
  Future<void> unsubscribe(SubscriptionModel subscription);
}
