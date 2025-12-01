import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

import '../../../authentification/data/models/user.model.dart';

class MainEntity extends Equatable {
  final UserModel user;
  final List<FriendsModel> friends;
  final List<TransactionModel> transactions;

  const MainEntity({
    required this.user,
    required this.friends,
    required this.transactions,
  });

  @override
  List<Object?> get props => [user, friends, transactions];

  factory MainEntity.fromEmpty() {
    return MainEntity(
      user: UserModel(
        uid: '',
        image: '',
        username: '',
        email: '',
        incomes: 0,
        expenses: 0,
        balance: 0,
        companyIncome: 0,
        personalIncome: 0,
      ),
      friends: [],
      transactions: [],
    );
  }
}
