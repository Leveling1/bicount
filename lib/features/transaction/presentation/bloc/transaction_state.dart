part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionCreated extends TransactionState {}

class TransactionError extends TransactionState {
  final Failure failure;

  TransactionError(this.failure);
}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  TransactionLoaded(this.transactions);
}

class TransactionLinkedUsersLoaded extends TransactionState {
  final List<UserEntity> users;

  TransactionLinkedUsersLoaded(this.users);
}
