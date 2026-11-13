part of 'transaction_repository_impl.dart';

extension on TransactionRepositoryImpl {
  Future<void> _createTransaction(
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      final partyTransactionType = _resolvePartyTransactionType(transaction);
      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _partyResolutionService.resolveParty(
        transaction.sender,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );
      final gtid = const Uuid().v4();
      final authenticatedUserId = _authenticatedUserIdOrNull();
      String? debtId;
      DebtModel? pendingDebt;
      String? principalTransactionId;

      // Create a recurring template if the user enabled recurring mode.
      String? originId;
      int? generationMode;
      var shouldSaveLedgerRows = true;
      if (transaction.isDebt) {
        if (resolvedSplits.length != 1) {
          throw MessageFailure(
            message: 'Debt creation supports one beneficiary only.',
          );
        }
        if (authenticatedUserId == null || authenticatedUserId.isEmpty) {
          throw AuthenticationFailure(message: 'Authentication failure');
        }

        final dueDate = transaction.debtDueDate;
        if (dueDate == null || dueDate.isEmpty) {
          throw MessageFailure(message: 'Debt due date is required.');
        }

        final firstBeneficiary = await _partyResolutionService.resolveParty(
          resolvedSplits.first.beneficiary,
          transactionType: partyTransactionType,
          resolvedParties: resolvedParties,
        );
        final now = DateTime.now().toIso8601String();
        final expectedRepaymentAmount =
            transaction.debtExpectedRepaymentAmount ?? transaction.totalAmount;
        debtId = const Uuid().v4();
        principalTransactionId = const Uuid().v4();
        originId = debtId;

        pendingDebt = DebtModel(
          debtId: debtId,
          createdBy: authenticatedUserId,
          lenderId: sender.sid,
          borrowerId: firstBeneficiary.sid,
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
          principalAmount: transaction.totalAmount,
          expectedRepaymentAmount: expectedRepaymentAmount,
          remainingAmount: expectedRepaymentAmount,
          expectedRepaymentCurrency: transaction.debtExpectedRepaymentCurrency,
          dueDate: dueDate,
          createdAt: now,
          updatedAt: now,
        );
      }

      if (!transaction.isDebt &&
          transaction.isRecurring &&
          transaction.recurringFrequency != null &&
          transaction.recurringTypeId != null) {
        final firstBeneficiary = await _partyResolutionService.resolveParty(
          resolvedSplits.first.beneficiary,
          transactionType: partyTransactionType,
          resolvedParties: resolvedParties,
        );
        final recurringOwnerId =
            authenticatedUserId ??
            (transaction.transactionType == 1
                ? firstBeneficiary.sid
                : sender.sid);
        final executionMode = _resolveRecurringExecutionMode(transaction);
        originId = const Uuid().v4();
        shouldSaveLedgerRows = _shouldSaveRecurringLedgerRows(transaction);
        generationMode = shouldSaveLedgerRows
            ? TransactionTypes.generationManualConfirmation
            : null;

        await _saveRecurringTransfert(
          RecurringTransfertModel(
            recurringTransfertId: originId,
            uid: recurringOwnerId,
            recurringTransfertTypeId: transaction.recurringTypeId!,
            title: transaction.name,
            note: transaction.note,
            amount: transaction.totalAmount,
            currency: transaction.currency,
            senderId: sender.sid,
            beneficiaryId: firstBeneficiary.sid,
            senderWalletId:
                transaction.transactionType == TransactionTypes.incomeCode
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
          ),
        );
      }

      if (!shouldSaveLedgerRows && originId != null) {
        return;
      }

      for (final split in resolvedSplits) {
        final beneficiary = await _partyResolutionService.resolveParty(
          split.beneficiary,
          transactionType: partyTransactionType,
          resolvedParties: resolvedParties,
        );
        final saveResult = await localDataSource.saveTransaction(
          gtid,
          transactionId: principalTransactionId,
          title: transaction.name,
          type: partyTransactionType,
          date: transaction.date,
          amount: split.amount,
          category: transaction.category,
          currency: transaction.currency,
          note: transaction.note,
          senderId: sender.sid,
          beneficiaryId: beneficiary.sid,
          senderWalletId:
              transaction.transactionType == TransactionTypes.incomeCode
              ? null
              : transaction.walletId,
          beneficiaryWalletId:
              transaction.transactionType == TransactionTypes.incomeCode
              ? transaction.walletId
              : null,
          image: beneficiary.image.isEmpty
              ? Constants.memojiDefault
              : beneficiary.image,
          originId: originId,
          originOccurrenceDate: transaction.isDebt || originId == null
              ? null
              : transaction.date,
          generationMode: generationMode,
        );

        final failure = saveResult.fold<Failure?>(
          (error) => error,
          (_) => null,
        );
        if (failure != null) await _throwFailure(failure);
      }
      if (pendingDebt != null) {
        try {
          await _saveDebt(pendingDebt);
        } catch (_) {
          final principal = await _findStoredTransaction(
            principalTransactionId!,
          );
          if (principal != null) await Repository().delete(principal);
          rethrow;
        }
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }
}
