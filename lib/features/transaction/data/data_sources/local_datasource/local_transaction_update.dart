part of 'local_transaction_data_source_impl.dart';

extension on LocalTransactionDataSourceImpl {
  Future<Either<Failure, void>> _updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required int type,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    String? senderWalletId,
    String? beneficiaryWalletId,
    required String beneficiaryId,
    required String image,
    int? frequency,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) async {
    final currentUid = _currentUid;
    final ownerUid = previousTransaction.uid ?? currentUid;
    if (ownerUid == null) {
      return _authenticationFailure();
    }

    try {
      final currentRecord = await _findStoredTransaction(
        previousTransaction.tid,
      );
      final quote = await _resolveUpdateQuote(
        currentRecord: currentRecord,
        previousTransaction: previousTransaction,
        amount: amount,
        currency: currency,
      );

      final transactionModel = TransactionModel(
        tid: previousTransaction.tid,
        uid: ownerUid,
        gtid: previousTransaction.gtid,
        name: title,
        type: type,
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        senderWalletId: senderWalletId ?? currentRecord?.senderWalletId,
        beneficiaryWalletId:
            beneficiaryWalletId ?? currentRecord?.beneficiaryWalletId,
        date: date,
        note: note,
        amount: amount,
        currency: currency,
        referenceCurrencyCode:
            currentRecord?.referenceCurrencyCode ?? quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        image: image,
        frequency:
            frequency ??
            currentRecord?.frequency ??
            previousTransaction.frequency,
        category: category,
        originId:
            originId ?? currentRecord?.originId ?? previousTransaction.originId,
        originOccurrenceDate:
            originOccurrenceDate ??
            currentRecord?.originOccurrenceDate ??
            previousTransaction.originOccurrenceDate,
        recurringTransfertId:
            TransactionTypes.expenseTypes.contains(type) ||
                TransactionTypes.incomeTypes.contains(type)
            ? originId ?? currentRecord?.recurringTransfertId
            : null,
        recurringOccurrenceDate:
            TransactionTypes.expenseTypes.contains(type) ||
                TransactionTypes.incomeTypes.contains(type)
            ? originOccurrenceDate ?? currentRecord?.recurringOccurrenceDate
            : null,
        generationMode: generationMode ?? currentRecord?.generationMode ?? 0,
        createdAt:
            currentRecord?.createdAt ??
            previousTransaction.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      );

      await Repository().upsert<TransactionModel>(transactionModel);

      return const Right(null);
    } on Failure catch (error) {
      return Left(error);
    } catch (_) {
      return _messageFailure('Unable to update this transaction right now.');
    }
  }
}
