import 'package:bicount/core/constants/subscription_const.dart';

class TransactionTypes {
  /// Transaction types
  static const transfer = 0;
  static const subscription = 1;
  static const addFund = 2;

  static const String transferText = 'Transfer';
  static const String subscriptionText = 'Subscription';
  static const String addFundText = 'Add a fund';

  static const personal = 3;
  static const business = 4;

  /// List of all transaction types
  static const List<String> allTypes = [
    'All',
    'Income',
    'Expense',
    'Subscription',
    'Other',
    'Personal',
    'Business',
  ];

  static const List<int> allTypesInt = [
    0,
    incomeCode,
    expenseCode,
    subscriptionCode,
    othersCode,
    personal,
    business,
  ];

  static const String income = "Income";
  static const String expense = "Expense";
  static const String others = "Other";
  static const String subscriptionTitle = "Subscription";

  static const int incomeCode = 1;
  static const int expenseCode = 2;
  static const int othersCode = 3;
  static const int subscriptionCode = 4;

  static const int personalIncome = 0;
  static const int companyIncome = 1;

  static String getTypeText(int type) {
    switch (type) {
      case incomeCode:
        return income;
      case expenseCode:
        return expense;
      case othersCode:
        return others;
      case subscriptionCode:
        return subscriptionTitle;
      default:
        return others;
    }
  }

  static String frequencyToString(int frequency) {
    switch (frequency) {
      case Frequency.oneTime:
        return Frequency.oneTimeString;
      case Frequency.weekly:
        return Frequency.weeklyString;
      case Frequency.monthly:
        return Frequency.monthlyString;
      case Frequency.quarterly:
        return Frequency.quarterlyString;
      case Frequency.yearly:
        return Frequency.yearlyString;
      default:
        return Frequency.oneTimeString;
    }
  }
}
