part of 'debt_repository_impl.dart';

extension on DebtRepositoryImpl {
  Future<void> _updateContract(UpdateDebtRequestEntity request) async {
    final debt = await localDataSource.findDebtById(request.debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    await _ensureCanManageContract(
      debt,
      failureMessage: 'Only the creator can update this debt for now.',
    );

    final normalizedCurrency = CurrencyConfigEntity.normalizeCode(
      request.currency,
    );
    if (request.principalAmount <= 0 || request.expectedRepaymentAmount <= 0) {
      throw MessageFailure(message: 'Enter an amount greater than zero.');
    }
    if (request.dueDate.isEmpty) {
      throw MessageFailure(message: 'Debt due date is required.');
    }

    final principalTransaction = await _findTransactionById(
      debt.principalTransactionId,
    );
    if (principalTransaction == null) {
      throw MessageFailure(message: 'Debt not found.');
    }

    final isLender = await _isWalletParty(debt.lenderId);
    final lenderWallet = isLender ? request.walletId : null;
    final borrowerWallet = (await _isWalletParty(debt.borrowerId))
        ? request.walletId
        : null;
    final provisionalDebt = DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      lenderWalletId: lenderWallet ?? debt.lenderWalletId,
      borrowerId: debt.borrowerId,
      borrowerWalletId: borrowerWallet ?? debt.borrowerWalletId,
      principalTransactionId: debt.principalTransactionId,
      title: request.title,
      note: request.note,
      currency: normalizedCurrency,
      principalAmount: request.principalAmount,
      expectedRepaymentAmount: request.expectedRepaymentAmount,
      repaidAmount: debt.repaidAmount,
      remainingAmount: debt.remainingAmount,
      dueDate: request.dueDate,
      status: debt.status,
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: debt.closedAt,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    final repaidAmount = await _sumLinkedRepaymentsInDebtCurrency(
      provisionalDebt,
    );
    if (request.expectedRepaymentAmount + _amountTolerance < repaidAmount) {
      throw MessageFailure(
        message:
            'Expected repayment amount cannot be lower than the amount already repaid.',
      );
    }

    final updateResult = await transactionLocalDataSource.updateTransaction(
      TransactionEntity.fromTransaction(principalTransaction),
      title: request.title,
      type: principalTransaction.type,
      date: request.principalDate,
      amount: request.principalAmount,
      category: principalTransaction.category ?? Constants.personal,
      currency: normalizedCurrency,
      note: request.note,
      senderId: principalTransaction.senderId,
      beneficiaryId: principalTransaction.beneficiaryId,
      senderWalletId: lenderWallet,
      beneficiaryWalletId: borrowerWallet,
      image: principalTransaction.image ?? Constants.memojiDefault,
    );
    await updateResult.fold(_throwFailure, (_) async => null);

    final remainingAmount =
        (request.expectedRepaymentAmount - repaidAmount).clamp(
              0,
              double.infinity,
            )
            as double;
    final updatedDebt = DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      lenderWalletId: lenderWallet ?? debt.lenderWalletId,
      borrowerId: debt.borrowerId,
      borrowerWalletId: borrowerWallet ?? debt.borrowerWalletId,
      principalTransactionId: debt.principalTransactionId,
      title: request.title,
      note: request.note,
      currency: normalizedCurrency,
      principalAmount: request.principalAmount,
      expectedRepaymentAmount: request.expectedRepaymentAmount,
      repaidAmount: repaidAmount,
      remainingAmount: remainingAmount,
      dueDate: request.dueDate,
      status: _resolveStatus(provisionalDebt, remainingAmount),
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: remainingAmount == 0 ? DateTime.now().toIso8601String() : null,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await localDataSource.updateDebt(updatedDebt);
  }
}
