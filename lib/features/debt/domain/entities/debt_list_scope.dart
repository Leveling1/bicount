enum DebtListScope { all, receivable, payable }

extension DebtListScopeX on DebtListScope {
  static DebtListScope fromQuery(String? value) {
    return switch (value) {
      'receivable' => DebtListScope.receivable,
      'payable' => DebtListScope.payable,
      _ => DebtListScope.all,
    };
  }

  String get queryValue {
    return switch (this) {
      DebtListScope.all => 'all',
      DebtListScope.receivable => 'receivable',
      DebtListScope.payable => 'payable',
    };
  }
}
