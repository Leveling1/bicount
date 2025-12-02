part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class CreateTransactionEvent extends TransactionEvent {
  final Map<String, dynamic> transaction;
  CreateTransactionEvent(this.transaction);
}

class AddSubscriptionEvent extends TransactionEvent {
  final SubscriptionEntity subscription;
  AddSubscriptionEvent(this.subscription);
}
