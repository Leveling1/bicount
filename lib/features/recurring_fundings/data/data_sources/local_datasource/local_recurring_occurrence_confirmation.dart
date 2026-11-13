part of 'local_recurring_transfert_data_source_impl.dart';

extension on LocalRecurringTransfertDataSourceImpl {
  Future<void> _confirmOccurrence(
    SalaryOccurrenceEntity occurrence, {
    required double confirmedAmount,
    required String confirmedCurrency,
    String? walletId,
    bool switchToAutomatic = false,
  }) async {
    final currentPlan = await _findRecurringTransfert(
      occurrence.recurringTransfert.recurringTransfertId ?? '',
    );
    if (currentPlan == null) {
      throw Exception('Recurring plan not found.');
    }

    final existingTransaction = await _findOccurrenceTransaction(
      currentPlan.recurringTransfertId ?? '',
      occurrence.expectedDate,
    );
    if (existingTransaction == null) {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: confirmedAmount,
        originalCurrencyCode: confirmedCurrency,
      );
      final transaction = TransactionModel(
        uid: _currentUid ?? currentPlan.uid,
        gtid: const Uuid().v4(),
        name: currentPlan.title,
        type: currentPlan.recurringTransfertTypeId,
        beneficiaryId: currentPlan.beneficiaryId,
        beneficiaryWalletId: walletId ?? currentPlan.beneficiaryWalletId,
        senderId: currentPlan.senderId,
        senderWalletId: currentPlan.senderWalletId,
        date: _scheduleService
            .mergeDateWithCurrentTime(occurrence.expectedDate)
            .toIso8601String(),
        note: currentPlan.note,
        amount: confirmedAmount,
        currency: confirmedCurrency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        frequency: Frequency.oneTime,
        category: Constants.personal,
        createdAt: DateTime.now().toIso8601String(),
        originId: currentPlan.recurringTransfertId,
        originOccurrenceDate: occurrence.expectedDate.toIso8601String(),
        recurringTransfertId: currentPlan.recurringTransfertId,
        recurringOccurrenceDate: occurrence.expectedDate.toIso8601String(),
        generationMode: TransactionTypes.generationManualConfirmation,
      );
      await Repository().upsert<TransactionModel>(
        transaction,
        isCreation: true,
      );
      if (_currentUid != null) {
        await _offlineFinanceLocalService.applyTransactionEffects(
          currentUserId: _currentUid!,
          transaction: transaction,
        );
      }
    }

    await Repository().upsert<RecurringTransfertModel>(
      RecurringTransfertModel(
        recurringTransfertId: currentPlan.recurringTransfertId,
        uid: _currentUid ?? currentPlan.uid,
        recurringTransfertTypeId: currentPlan.recurringTransfertTypeId,
        title: currentPlan.title,
        note: currentPlan.note,
        amount: currentPlan.amount,
        currency: currentPlan.currency,
        senderId: currentPlan.senderId,
        senderWalletId: currentPlan.senderWalletId,
        beneficiaryId: currentPlan.beneficiaryId,
        beneficiaryWalletId:
            (switchToAutomatic ? walletId : null) ??
            currentPlan.beneficiaryWalletId,
        frequency: currentPlan.frequency,
        startDate: currentPlan.startDate,
        nextDueDate: currentPlan.nextDueDate,
        endDate: currentPlan.endDate,
        status: currentPlan.status,
        executionMode: switchToAutomatic
            ? AppExecutionMode.backendAutomatic
            : currentPlan.executionMode,
        reminderEnabled: switchToAutomatic
            ? false
            : currentPlan.reminderEnabled,
        lastGeneratedAt: currentPlan.lastGeneratedAt,
        lastConfirmedAt: DateTime.now().toIso8601String(),
        createdAt: currentPlan.createdAt,
      ),
    );
  }
}
