
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(Map<String, dynamic> transaction);
  Future<void> addSubscription(SubscriptionEntity subscription);
  Future<void> unsubscribe(SubscriptionModel subscription);
}
