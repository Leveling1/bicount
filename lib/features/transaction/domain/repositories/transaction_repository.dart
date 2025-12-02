
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(Map<String, dynamic> transaction);
  Future<void> addSubscription(SubscriptionEntity subscription);
}
