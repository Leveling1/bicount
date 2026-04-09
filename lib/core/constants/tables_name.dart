class TablesName {
  static const String users = 'users';
  static const String companies = 'companies';
  static const String companyWithUserLink = 'company_with_user_link';
  static const String groups = 'groups';
  static const String friends = 'friends';
  static const String projects = 'projects';
  static const String transactions = 'transactions';
  static const String recurringTransfert = 'recurring_transfert';
  static const String accounts = 'accounts';

  /// Legacy table names kept for migration cleanup.
  static const String accountFunding = 'account_funding';
  static const String recurringFundings = 'recurring_fundings';
  static const String subscriptions = 'subscriptions';

  static const List<String> listTable = [
    TablesName.users,
    TablesName.companies,
    TablesName.companyWithUserLink,
    TablesName.groups,
    TablesName.friends,
    TablesName.projects,
    TablesName.transactions,
    TablesName.recurringTransfert,
    TablesName.accounts,
  ];
}
