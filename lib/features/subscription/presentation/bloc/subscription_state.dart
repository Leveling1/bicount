part of 'subscription_bloc.dart';

abstract class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionSaving extends SubscriptionState {}

class SubscriptionSaved extends SubscriptionState {}

class SubscriptionUnsubscribing extends SubscriptionState {}

class SubscriptionUnsubscribed extends SubscriptionState {}

class SubscriptionFailure extends SubscriptionState {
  const SubscriptionFailure(this.message);

  final String message;
}
