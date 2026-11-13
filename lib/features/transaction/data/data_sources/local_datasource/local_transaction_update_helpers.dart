part of 'local_transaction_data_source_impl.dart';

extension on LocalTransactionDataSourceImpl {
  Future<TransactionModel?> _findStoredTransaction(String tid) async {
    if (tid.isEmpty) {
      return null;
    }

    final items = await Repository().get<TransactionModel>(
      policy: OfflineReadPolicy.localOnly,
      query: Query(where: [Where.exact('tid', tid)]),
    );
    return items.isEmpty ? null : items.first;
  }

  Future<CurrencyQuoteEntity> _resolveUpdateQuote({
    required TransactionModel? currentRecord,
    required TransactionEntity previousTransaction,
    required double amount,
    required String currency,
  }) async {
    final referenceCurrencyCode = currentRecord?.referenceCurrencyCode;
    MessageFailure? historicalRateFailure;

    for (final rateDate in _resolveHistoricalRateDateCandidates(
      currentRecord,
      previousTransaction,
    )) {
      try {
        return await _currencyRepository.resolveHistoricalQuote(
          amount: amount,
          originalCurrencyCode: currency,
          rateDate: rateDate,
          referenceCurrencyCode: referenceCurrencyCode,
        );
      } on MessageFailure catch (error) {
        historicalRateFailure = error;
      }
    }

    if (historicalRateFailure != null) {
      throw historicalRateFailure;
    }

    return _currencyRepository.resolveCreationQuote(
      amount: amount,
      originalCurrencyCode: currency,
    );
  }

  Iterable<String> _resolveHistoricalRateDateCandidates(
    TransactionModel? currentRecord,
    TransactionEntity previousTransaction,
  ) sync* {
    final fxRateDate = currentRecord?.fxRateDate;
    if (fxRateDate != null && fxRateDate.isNotEmpty) {
      yield fxRateDate;
    }

    final createdAt =
        currentRecord?.createdAt ??
        previousTransaction.createdAt?.toIso8601String();
    if (createdAt != null && createdAt.isNotEmpty && createdAt != fxRateDate) {
      yield createdAt;
    }
  }
}
