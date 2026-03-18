part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class CreateTransactionEvent extends TransactionEvent {
  CreateTransactionEvent(this.transaction);

  final CreateTransactionRequestEntity transaction;
}

class AddSubscriptionEvent extends TransactionEvent {
  AddSubscriptionEvent(this.subscription);

  final SubscriptionEntity subscription;
}

class UnsubscribeEvent extends TransactionEvent {
  UnsubscribeEvent(this.subscription);

  final SubscriptionModel subscription;
}
