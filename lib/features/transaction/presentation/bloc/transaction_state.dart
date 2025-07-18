part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

// Add your states here
class TransactionLoading extends TransactionState {}
