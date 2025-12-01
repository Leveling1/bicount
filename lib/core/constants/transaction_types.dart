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
    'Transfer',
    'Personal',
    'Business',
  ];

  static const int personalIncome = 0;
  static const int companyIncome = 1;
}
