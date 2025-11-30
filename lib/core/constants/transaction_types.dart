class TransactionTypes {
  /// Transaction types
  static const expense = 0;
  static const income = 1;
  static const transfer = 2;
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
