import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

import '../../../authentification/data/models/user.model.dart';

class MainEntity extends Equatable {
  final UserModel user;
  final int connectionState;
  final String referenceCurrencyCode;
  final List<FriendsModel> friends;
  final List<TransactionModel> transactions;
  final List<RecurringTransfertModel> recurringTransferts;

  const MainEntity({
    required this.user,
    required this.connectionState,
    required this.referenceCurrencyCode,
    required this.friends,
    required this.transactions,
    required this.recurringTransferts,
  });

  @override
  List<Object?> get props => [
    user,
    referenceCurrencyCode,
    friends,
    transactions,
    recurringTransferts,
  ];

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
        referenceCurrencyCode: 'CDF',
      ),
      connectionState: Constants.disconnected,
      referenceCurrencyCode: 'CDF',
      friends: [],
      transactions: [],
      recurringTransferts: [],
    );
  }
}
