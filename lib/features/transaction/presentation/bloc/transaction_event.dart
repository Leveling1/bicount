part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class CreateTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  CreateTransactionEvent(this.transaction);
}

class GetAllTransactionsRequested extends TransactionEvent {}

class GetLinkedUsersRequested extends TransactionEvent {}
