part of 'transaction_repository_impl.dart';

extension on TransactionRepositoryImpl {
  Future<String> _createDebtContractFromTransaction({
    required String ownerUid,
    required String principalTransactionId,
    required CreateTransactionRequestEntity transaction,
    required double amount,
    required _ResolvedParty sender,
    required _ResolvedParty beneficiary,
  }) async {
    final dueDate = transaction.debtDueDate;
    if (dueDate == null || dueDate.isEmpty) {
      throw MessageFailure(message: 'Debt due date is required.');
    }

    final now = DateTime.now().toIso8601String();
    final debtId = const Uuid().v4();
    final expectedRepaymentAmount =
        transaction.debtExpectedRepaymentAmount ?? amount;

    await _saveDebt(
      DebtModel(
        debtId: debtId,
        createdBy: ownerUid,
        lenderId: sender.sid,
        borrowerId: beneficiary.sid,
        lenderWalletId:
            transaction.transactionType == TransactionTypes.incomeCode
            ? null
            : transaction.walletId,
        borrowerWalletId:
            transaction.transactionType == TransactionTypes.incomeCode
            ? transaction.walletId
            : null,
        principalTransactionId: principalTransactionId,
        title: transaction.name,
        note: transaction.note,
        currency: transaction.currency,
        principalAmount: amount,
        expectedRepaymentAmount: expectedRepaymentAmount,
        remainingAmount: expectedRepaymentAmount,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return debtId;
  }

  Future<RecurringTransfertModel> _createRecurringTransfertFromTransaction({
    required String ownerUid,
    required CreateTransactionRequestEntity transaction,
    required double amount,
    required _ResolvedParty sender,
    required _ResolvedParty beneficiary,
  }) async {
    final executionMode = _resolveRecurringExecutionMode(transaction);
    final recurringTransfert = RecurringTransfertModel(
      recurringTransfertId: const Uuid().v4(),
      uid: ownerUid,
      recurringTransfertTypeId: transaction.recurringTypeId!,
      title: transaction.name,
      note: transaction.note,
      amount: amount,
      currency: transaction.currency,
      senderId: sender.sid,
      beneficiaryId: beneficiary.sid,
      senderWalletId: transaction.transactionType == TransactionTypes.incomeCode
          ? null
          : transaction.walletId,
      beneficiaryWalletId:
          transaction.transactionType == TransactionTypes.incomeCode
          ? transaction.walletId
          : null,
      frequency: transaction.recurringFrequency!,
      startDate: transaction.date,
      nextDueDate: transaction.date,
      executionMode: executionMode,
      reminderEnabled: _resolveRecurringReminderEnabled(
        transaction,
        executionMode,
      ),
      createdAt: DateTime.now().toIso8601String(),
    );

    await _saveRecurringTransfert(recurringTransfert);
    return recurringTransfert;
  }

  Future<void> _cleanupConvertedArtifacts({
    String? debtId,
    RecurringTransfertModel? recurringTransfert,
  }) async {
    if (debtId != null) {
      try {
        await _deleteDebt(debtId);
      } catch (_) {}
    }

    if (recurringTransfert != null) {
      try {
        await _deleteRecurringTransfert(recurringTransfert);
      } catch (_) {}
    }
  }

  Future<void> _deleteRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    await Repository().delete<RecurringTransfertModel>(recurringTransfert);
  }
}
