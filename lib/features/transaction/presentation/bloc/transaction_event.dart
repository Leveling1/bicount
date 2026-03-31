part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class CreateTransactionEvent extends TransactionEvent {
  CreateTransactionEvent(this.transaction);

  final CreateTransactionRequestEntity transaction;
}

class DeleteTransactionEvent extends TransactionEvent {
  DeleteTransactionEvent(this.transaction);

  final TransactionEntity transaction;
}

class UpdateTransactionEvent extends TransactionEvent {
  UpdateTransactionEvent(this.previousTransaction, this.transaction);

  final TransactionEntity previousTransaction;
  final CreateTransactionRequestEntity transaction;
}
