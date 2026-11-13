part of 'debt_repository_impl.dart';

extension on DebtRepositoryImpl {
  Future<void> _recordPayment(RecordDebtPaymentRequestEntity request) async {
    final debt = await localDataSource.findDebtById(request.debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    final requestCurrency = CurrencyConfigEntity.normalizeCode(
      request.currency,
    );
    if (request.amount <= 0 || requestCurrency.isEmpty) {
      throw MessageFailure(message: 'Enter a valid repayment amount.');
    }

    final debtCurrencyAmount = await _convertToDebtCurrency(
      amount: request.amount,
      originalCurrencyCode: requestCurrency,
      debtCurrencyCode: debt.currency,
    );

    if (debtCurrencyAmount > debt.remainingAmount + _amountTolerance) {
      throw MessageFailure(
        message: 'Repayment amount cannot exceed the remaining balance.',
      );
    }

    await _ensureCanRecordPayment(debt);

    final gtid = const Uuid().v4();
    final saveResult = await transactionLocalDataSource.saveTransaction(
      gtid,
      title: debt.title,
      type: TransactionTypes.debtCode,
      date: DateTime.now().toIso8601String(),
      amount: request.amount,
      category: Constants.personal,
      currency: requestCurrency,
      note: debt.note,
      senderId: debt.borrowerId,
      beneficiaryId: debt.lenderId,
      senderWalletId: (await _isWalletParty(debt.borrowerId))
          ? request.walletId
          : null,
      beneficiaryWalletId: (await _isWalletParty(debt.lenderId))
          ? request.walletId
          : null,
      image: Constants.memojiDefault,
      originId: debt.debtId,
      generationMode: TransactionTypes.generationOneTime,
    );
    await saveResult.fold(_throwFailure, (_) async => null);

    final updatedDebt = await _rebuildDebtFromTransactions(debt);
    await localDataSource.updateDebt(updatedDebt);
  }
}
