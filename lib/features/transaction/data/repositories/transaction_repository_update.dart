part of 'transaction_repository_impl.dart';

extension on TransactionRepositoryImpl {
  Future<void> _updateTransaction(
    TransactionEntity previousTransaction,
    CreateTransactionRequestEntity transaction,
  ) async {
    String? createdDebtId;
    RecurringTransfertModel? createdRecurringTransfert;
    final currentUid = _authenticatedUserIdOrNull();
    final ownerUid = previousTransaction.uid ?? currentUid;
    if (ownerUid == null) {
      throw AuthenticationFailure(message: 'Authentication failure');
    }

    try {
      final principalDebt = await _findPrincipalDebt(previousTransaction);
      if (principalDebt != null && _debtRepository != null) {
        final resolvedSplits = splitResolver.resolve(transaction);
        if (resolvedSplits.length != 1) {
          throw MessageFailure(
            message: 'Debt creation supports one beneficiary only.',
          );
        }

        await _debtRepository.updateDebtContract(
          UpdateDebtRequestEntity(
            debtId: principalDebt.debtId ?? '',
            title: transaction.name,
            note: transaction.note,
            principalDate: transaction.date,
            principalAmount: resolvedSplits.single.amount,
            currency: transaction.currency,
            walletId: transaction.walletId,
            dueDate: transaction.debtDueDate ?? principalDebt.dueDate,
            expectedRepaymentAmount:
                transaction.debtExpectedRepaymentAmount ??
                principalDebt.expectedRepaymentAmount,
          ),
        );
        return;
      }

      if (previousTransaction.type == TransactionTypes.debtCode &&
          previousTransaction.originId != null &&
          previousTransaction.originId!.isNotEmpty) {
        throw MessageFailure(
          message: 'Debt repayments can only be managed from the debts screen.',
        );
      }

      final currentRecord = await _findStoredTransaction(
        previousTransaction.tid,
      );
      final resolvedSplits = splitResolver.resolve(transaction);
      final partyTransactionType = _resolvePartyTransactionType(transaction);
      if (resolvedSplits.length != 1) {
        throw MessageFailure(
          message: 'Edit this transaction with one beneficiary only.',
        );
      }

      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _partyResolutionService.resolveParty(
        transaction.sender,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );
      final split = resolvedSplits.single;
      final beneficiary = await _partyResolutionService.resolveParty(
        split.beneficiary,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );

      final storedOriginId =
          currentRecord?.originId ?? previousTransaction.originId;
      final canConvertBaseTransaction =
          storedOriginId == null || storedOriginId.isEmpty;
      if (!canConvertBaseTransaction &&
          (transaction.isDebt || transaction.isRecurring)) {
        throw MessageFailure(
          message: 'Derived transactions cannot be converted from here.',
        );
      }

      String? originId =
          currentRecord?.originId ?? previousTransaction.originId;
      String? originOccurrenceDate =
          currentRecord?.originOccurrenceDate ??
          previousTransaction.originOccurrenceDate;
      int? frequency =
          currentRecord?.frequency ?? previousTransaction.frequency;
      int? generationMode = currentRecord?.generationMode;

      if (canConvertBaseTransaction && transaction.isDebt) {
        createdDebtId = await _createDebtContractFromTransaction(
          ownerUid: ownerUid,
          principalTransactionId: previousTransaction.tid,
          transaction: transaction,
          amount: split.amount,
          sender: sender,
          beneficiary: beneficiary,
        );
        originId = createdDebtId;
        originOccurrenceDate = null;
        frequency = Frequency.oneTime;
        generationMode = TransactionTypes.generationConverted;
      } else if (canConvertBaseTransaction &&
          transaction.isRecurring &&
          transaction.recurringFrequency != null &&
          transaction.recurringTypeId != null) {
        createdRecurringTransfert =
            await _createRecurringTransfertFromTransaction(
              ownerUid: ownerUid,
              transaction: transaction,
              amount: split.amount,
              sender: sender,
              beneficiary: beneficiary,
            );
        originId = createdRecurringTransfert.recurringTransfertId;
        originOccurrenceDate = transaction.date;
        frequency = transaction.recurringFrequency;
        generationMode = TransactionTypes.generationConverted;
      }

      final result = await localDataSource.updateTransaction(
        previousTransaction,
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
        frequency: frequency,
        originId: originId,
        originOccurrenceDate: originOccurrenceDate,
        generationMode: generationMode,
      );

      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      await _cleanupConvertedArtifacts(
        debtId: createdDebtId,
        recurringTransfert: createdRecurringTransfert,
      );
      rethrow;
    } catch (_) {
      await _cleanupConvertedArtifacts(
        debtId: createdDebtId,
        recurringTransfert: createdRecurringTransfert,
      );
      throw UnknownFailure();
    }
  }
}
