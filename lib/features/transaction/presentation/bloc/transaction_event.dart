part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

// Add your events here
class CreateTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;

  CreateTransactionEvent(this.transaction);
}
