import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

class MainEntity extends Equatable {
  final List<TransactionModel> transactions;

  const MainEntity({required this.transactions});

  @override
  List<Object?> get props => [transactions];

  factory MainEntity.fromEmpty() {
    return MainEntity(transactions: []);
  }
}