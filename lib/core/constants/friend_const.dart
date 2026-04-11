import 'package:bicount/core/constants/transaction_types.dart';

class FriendConst {
  static const int friend = 0;
  static const int subscription = 1;
  static const int workFriend = 2;
  static const int company = 3;

  static int getTypeOfFriend(int type) {
    switch (type) {
      case TransactionTypes.expenseCode:
      case TransactionTypes.incomeCode:
      case TransactionTypes.otherRecurringExpenseCode:
      case TransactionTypes.otherRecurringIncomeCode:
        return friend;
      case TransactionTypes.subscriptionCode:
        return subscription;
      case TransactionTypes.salaryCode:
        return company;
      default:
        return friend;
    }
  }
}
