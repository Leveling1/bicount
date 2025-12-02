part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}
class TransactionCreated extends TransactionState {}
class TransactionError extends TransactionState {
  final Failure failure;
  TransactionError(this.failure);
}
class TransactionLinkedUsersLoaded extends TransactionState {
  final List<UserEntity> users;
  TransactionLinkedUsersLoaded(this.users);
}

// Subscription states
class SubscriptionLoading extends TransactionState {}
class SubscriptionAdded extends TransactionState {}
class SubscriptionError extends TransactionState {
  final String message;
  SubscriptionError(this.message);
}