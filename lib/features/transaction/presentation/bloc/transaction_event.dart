part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class CreateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  CreateTransactionEvent(this.transaction);
}

class GetLinkedUsersRequested extends TransactionEvent {}
