part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionCreated extends TransactionState {}

class TransactionDeleted extends TransactionState {}

class TransactionUpdated extends TransactionState {}

class TransactionError extends TransactionState {
  final Failure failure;
  TransactionError(this.failure);
}
