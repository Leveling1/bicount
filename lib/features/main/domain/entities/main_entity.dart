import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

import '../../../authentification/data/models/user.model.dart';

class MainEntity extends Equatable {
  final List<UserModel> usersLink;
  final List<TransactionModel> transactions;

  const MainEntity({required this.usersLink, required this.transactions});

  @override
  List<Object?> get props => [usersLink, transactions];

  factory MainEntity.fromEmpty() {
    return MainEntity(
      usersLink: [],
      transactions: []
    );
  }
}