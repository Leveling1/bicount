part of 'transaction_repository_impl_test_support.dart';

FriendsModel currentUser() {
  return FriendsModel(
    sid: 'user-1',
    uid: 'user-1',
    username: 'Louis',
    image: '',
    email: 'louis@example.com',
    relationType: FriendConst.friend,
  );
}

FriendsModel draftParty({required String username, required int relationType}) {
  return FriendsModel(
    sid: '',
    uid: '',
    username: username,
    image: '',
    email: '',
    relationType: relationType,
  );
}

CreateTransactionRequestEntity recurringExpenseRequest(FriendsModel party) {
  return CreateTransactionRequestEntity(
    name: 'Subscription payment',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 19.99,
    currency: 'USD',
    sender: currentUser(),
    note: '',
    transactionType: TransactionTypes.expenseCode,
    splitMode: TransactionSplitMode.equal,
    splits: [TransactionSplitInputEntity(beneficiary: party)],
    isRecurring: true,
    recurringFrequency: 1,
    recurringTypeId: TransactionTypes.subscriptionCode,
  );
}

CreateTransactionRequestEntity recurringSalaryRequest(
  FriendsModel employer, {
  int executionMode = AppExecutionMode.manualConfirmation,
  bool reminderEnabled = true,
}) {
  return CreateTransactionRequestEntity(
    name: 'Monthly salary',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 1200,
    currency: 'USD',
    sender: employer,
    note: '',
    transactionType: TransactionTypes.incomeCode,
    splitMode: TransactionSplitMode.equal,
    splits: [TransactionSplitInputEntity(beneficiary: currentUser())],
    isRecurring: true,
    recurringFrequency: 1,
    recurringTypeId: TransactionTypes.salaryCode,
    recurringExecutionMode: executionMode,
    recurringReminderEnabled: reminderEnabled,
  );
}

CreateTransactionRequestEntity debtUpdateRequest() {
  return CreateTransactionRequestEntity(
    name: 'Updated debt',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 80,
    currency: 'USD',
    sender: currentUser(),
    note: 'Updated note',
    transactionType: TransactionTypes.expenseCode,
    splitMode: TransactionSplitMode.equal,
    splits: [
      TransactionSplitInputEntity(
        beneficiary: draftParty(
          username: 'Alice',
          relationType: FriendConst.friend,
        ),
      ),
    ],
    isDebt: true,
    debtDueDate: DateTime(2026, 5, 1).toIso8601String(),
    debtExpectedRepaymentAmount: 95,
  );
}

CreateTransactionRequestEntity incomeDebtUpdateRequest() {
  return CreateTransactionRequestEntity(
    name: 'Updated income debt',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 80,
    currency: 'USD',
    sender: draftParty(username: 'Employer', relationType: FriendConst.friend),
    note: 'Updated income note',
    transactionType: TransactionTypes.incomeCode,
    splitMode: TransactionSplitMode.equal,
    splits: [TransactionSplitInputEntity(beneficiary: currentUser())],
    isDebt: true,
    debtDueDate: DateTime(2026, 5, 1).toIso8601String(),
    debtExpectedRepaymentAmount: 95,
  );
}

TransactionEntity debtPrincipalTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'principal-1',
    gtid: 'group-1',
    name: 'Debt',
    type: TransactionTypes.debtCode,
    date: DateTime(2026, 4, 10),
    amount: 100,
    currency: 'USD',
    originId: 'debt-1',
    sender: 'user-1',
    beneficiary: 'friend-1',
    note: '',
  );
}

TransactionEntity debtRepaymentTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'repayment-1',
    gtid: 'group-2',
    name: 'Repayment',
    type: TransactionTypes.debtCode,
    date: DateTime(2026, 4, 12),
    amount: 20,
    currency: 'USD',
    originId: 'debt-1',
    sender: 'friend-1',
    beneficiary: 'user-1',
    note: '',
  );
}

TransactionEntity convertibleExpenseTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'expense-1',
    gtid: 'group-expense-1',
    name: 'Lunch',
    type: TransactionTypes.expenseCode,
    date: DateTime(2026, 4, 9),
    amount: 45,
    currency: 'USD',
    sender: 'user-1',
    beneficiary: 'friend-1',
    note: 'Team lunch',
  );
}

TransactionEntity convertibleIncomeTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'income-1',
    gtid: 'group-income-1',
    name: 'Consulting',
    type: TransactionTypes.incomeCode,
    date: DateTime(2026, 4, 9),
    amount: 1500,
    currency: 'USD',
    sender: 'friend-1',
    beneficiary: 'user-1',
    note: 'Monthly consulting',
  );
}

DebtModel principalDebtModel() {
  return DebtModel(
    debtId: 'debt-1',
    createdBy: 'user-1',
    lenderId: 'user-1',
    borrowerId: 'friend-1',
    principalTransactionId: 'principal-1',
    title: 'Debt',
    currency: 'USD',
    principalAmount: 100,
    expectedRepaymentAmount: 100,
    remainingAmount: 100,
    dueDate: DateTime(2026, 5, 1).toIso8601String(),
  );
}
