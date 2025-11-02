import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

import '../../../authentification/data/models/user.model.dart';

class MainEntity extends Equatable {
  final UserModel user;
  final List<UserModel> usersLink;
  final List<TransactionModel> transactions;

  const MainEntity({required this.user, required this.usersLink, required this.transactions});

  @override
  List<Object?> get props => [user, usersLink, transactions];

  factory MainEntity.fromEmpty() {
    return MainEntity(
      user: UserModel(
        uid: '',
        username: '',
        email: '',
        sales: 0,
        expenses: 0,
        profit: 0,
        companyIncome: 0,
        personalIncome: 0,
      ),
      usersLink: [],
      transactions: []
    );
  }
}