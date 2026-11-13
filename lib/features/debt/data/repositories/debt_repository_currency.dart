part of 'debt_repository_impl.dart';

extension on DebtRepositoryImpl {
  Future<double> _sumLinkedRepaymentsInDebtCurrency(DebtModel debt) async {
    final linkedTransactions = await _findLinkedTransactions(debt.debtId ?? '');
    var repaidAmount = 0.0;
    for (final transaction in linkedTransactions) {
      if (transaction.tid == debt.principalTransactionId) {
        continue;
      }

      repaidAmount += await _convertTransactionToDebtCurrency(
        transaction,
        debtCurrencyCode: debt.currency,
      );
    }
    return repaidAmount;
  }

  Future<double> _convertToDebtCurrency({
    required double amount,
    required String originalCurrencyCode,
    required String debtCurrencyCode,
  }) async {
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      originalCurrencyCode,
    );
    final normalizedDebt = CurrencyConfigEntity.normalizeCode(debtCurrencyCode);
    if (normalizedOriginal == normalizedDebt) {
      return amount;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: amount,
      originalCurrencyCode: normalizedOriginal,
    );
    return _convertCdfAmountToCurrency(
      amountCdf: quote.amountCdf,
      targetCurrencyCode: normalizedDebt,
      fxRateDate: quote.fxRateDate,
    );
  }

  Future<double> _convertTransactionToDebtCurrency(
    TransactionModel transaction, {
    required String debtCurrencyCode,
  }) async {
    final normalizedDebt = CurrencyConfigEntity.normalizeCode(debtCurrencyCode);
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      transaction.currency,
    );
    if (normalizedOriginal == normalizedDebt) {
      return transaction.amount;
    }

    final amountCdf =
        transaction.amountCdf ??
        await _resolveTransactionAmountCdf(transaction);
    return _convertCdfAmountToCurrency(
      amountCdf: amountCdf,
      targetCurrencyCode: normalizedDebt,
      fxRateDate: transaction.fxRateDate,
    );
  }

  Future<double> _resolveTransactionAmountCdf(
    TransactionModel transaction,
  ) async {
    final fxRateDate = transaction.fxRateDate;
    if (fxRateDate != null && fxRateDate.isNotEmpty) {
      final quote = await _currencyRepository.resolveHistoricalQuote(
        amount: transaction.amount,
        originalCurrencyCode: transaction.currency,
        rateDate: fxRateDate,
        referenceCurrencyCode:
            CurrencyConfigEntity.defaultReferenceCurrencyCode,
      );
      return quote.amountCdf;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: transaction.amount,
      originalCurrencyCode: transaction.currency,
    );
    return quote.amountCdf;
  }

  Future<double> _convertCdfAmountToCurrency({
    required double amountCdf,
    required String targetCurrencyCode,
    String? fxRateDate,
  }) async {
    final normalizedTarget = CurrencyConfigEntity.normalizeCode(
      targetCurrencyCode,
    );
    if (normalizedTarget == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return amountCdf;
    }

    final rateToCdf = await _resolveCurrencyRateToCdf(
      currencyCode: normalizedTarget,
      fxRateDate: fxRateDate,
    );
    if (rateToCdf == null || rateToCdf <= 0) {
      throw MessageFailure(
        message: 'Unable to load the latest exchange rates right now.',
      );
    }

    return amountCdf / rateToCdf;
  }

  Future<double?> _resolveCurrencyRateToCdf({
    required String currencyCode,
    String? fxRateDate,
  }) async {
    if (currencyCode == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return 1;
    }

    if (fxRateDate != null && fxRateDate.isNotEmpty) {
      try {
        final quote = await _currencyRepository.resolveHistoricalQuote(
          amount: 1,
          originalCurrencyCode: currencyCode,
          rateDate: fxRateDate,
          referenceCurrencyCode:
              CurrencyConfigEntity.defaultReferenceCurrencyCode,
        );
        return quote.amountCdf;
      } on MessageFailure {
        rethrow;
      } catch (_) {}
    }

    try {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: 1,
        originalCurrencyCode: currencyCode,
      );
      return quote.amountCdf;
    } on MessageFailure {
      rethrow;
    } catch (_) {
      return _currencyRepository.currentConfig.latestRateToCdf(currencyCode);
    }
  }
}
