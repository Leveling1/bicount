import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:equatable/equatable.dart';

import '../../../authentification/data/models/user.model.dart';

class MainEntity extends Equatable {
  final UserModel user;
  final int connectionState;
  final String referenceCurrencyCode;
  final double monthlySubscriptionSpend;
  final List<FriendsModel> friends;
  final List<SubscriptionModel> subscriptions;
  final List<TransactionModel> transactions;
  final List<AccountFundingModel> accountFundings;

  const MainEntity({
    required this.user,
    required this.connectionState,
    required this.referenceCurrencyCode,
    required this.monthlySubscriptionSpend,
    required this.friends,
    required this.subscriptions,
    required this.transactions,
    required this.accountFundings,
  });

  @override
  List<Object?> get props => [
    user,
    referenceCurrencyCode,
    monthlySubscriptionSpend,
    friends,
    subscriptions,
    transactions,
    accountFundings,
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
      monthlySubscriptionSpend: 0,
      friends: [],
      subscriptions: [],
      transactions: [],
      accountFundings: [],
    );
  }
}
