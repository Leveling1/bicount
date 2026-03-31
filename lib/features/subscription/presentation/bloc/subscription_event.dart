part of 'subscription_bloc.dart';

abstract class SubscriptionEvent {
  const SubscriptionEvent();
}

class AddSubscriptionRequested extends SubscriptionEvent {
  const AddSubscriptionRequested(this.subscription);

  final SubscriptionEntity subscription;
}

class DeleteSubscriptionRequested extends SubscriptionEvent {
  const DeleteSubscriptionRequested(this.subscription);

  final SubscriptionModel subscription;
}

class UpdateSubscriptionRequested extends SubscriptionEvent {
  const UpdateSubscriptionRequested(this.subscription);

  final SubscriptionEntity subscription;
}

class UnsubscribeRequested extends SubscriptionEvent {
  const UnsubscribeRequested(this.subscription);

  final SubscriptionModel subscription;
}
