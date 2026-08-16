import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class CurrencyAmountService {
  const CurrencyAmountService();

  double transaction(TransactionModel model, CurrencyConfigEntity config) {
    return record(
      originalAmount: model.amount,
      originalCurrencyCode: model.currency,
      amountCdf: model.amountCdf,
      convertedAmount: model.convertedAmount,
      referenceCurrencyCode: model.referenceCurrencyCode,
      rateToCdf: model.rateToCdf,
      fxRateDate: model.fxRateDate,
      config: config,
    );
  }

  double record({
    required double originalAmount,
    required String originalCurrencyCode,
    required CurrencyConfigEntity config,
    double? amountCdf,
    double? convertedAmount,
    double? rateToCdf,
    String? referenceCurrencyCode,
    String? fxRateDate,
  }) {
    final normalizedReference = CurrencyConfigEntity.normalizeCode(
      config.referenceCurrencyCode,
    );
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      originalCurrencyCode,
    );
    final normalizedStoredReference = CurrencyConfigEntity.normalizeCode(
      referenceCurrencyCode,
    );
    final normalizedDate = fxRateDate == null || fxRateDate.isEmpty
        ? null
        : CurrencyConfigEntity.normalizeDate(fxRateDate);

    // If the current display currency matches the record's native currency,
    // preserve the exact original amount instead of reconstructing it from CDF.
    if (normalizedOriginal == normalizedReference) {
      return originalAmount;
    }

    // If the current display currency matches the reference currency captured
    // at creation time, prefer the stored converted amount when available.
    if (normalizedStoredReference == normalizedReference &&
        convertedAmount != null) {
      return convertedAmount;
    }

    final normalizedCdfAmount =
        amountCdf ??
        _resolveFallbackAmountCdf(
          originalAmount: originalAmount,
          originalCurrencyCode: normalizedOriginal,
          normalizedDate: normalizedDate,
          rateToCdf: rateToCdf,
          convertedAmount: convertedAmount,
          referenceCurrencyCode: referenceCurrencyCode,
          config: config,
        );

    // No rate for the source currency: the amount could not be expressed in
    // CDF, so dividing it by the target rate would not convert anything — it
    // would shrink a real amount by three orders of magnitude and present the
    // result as a total. 493.64 CAD came out as 0.22 $ that way. Returning it
    // unconverted keeps the magnitude honest until the rate is available.
    if (normalizedCdfAmount == null) {
      return convertedAmount ?? originalAmount;
    }

    if (normalizedReference ==
        CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return normalizedCdfAmount;
    }

    final targetRate =
        (normalizedDate == null
            ? null
            : config
                  .snapshotFor(
                    currencyCode: normalizedReference,
                    rateDate: normalizedDate,
                  )
                  ?.rateToCdf) ??
        config.latestRateToCdf(normalizedReference);

    if (targetRate == null || targetRate == 0) {
      return convertedAmount ?? normalizedCdfAmount;
    }

    return normalizedCdfAmount / targetRate;
  }

  /// CDF value of [originalAmount], or null when no rate lets us compute it.
  /// Null is deliberate: it used to return the amount untouched, which the
  /// caller then treated as if it were already in CDF.
  double? _resolveFallbackAmountCdf({
    required double originalAmount,
    required String originalCurrencyCode,
    required CurrencyConfigEntity config,
    String? normalizedDate,
    double? rateToCdf,
    double? convertedAmount,
    String? referenceCurrencyCode,
  }) {
    if (originalCurrencyCode ==
        CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return originalAmount;
    }

    final sourceRate =
        rateToCdf ??
        (normalizedDate == null
            ? null
            : config
                  .snapshotFor(
                    currencyCode: originalCurrencyCode,
                    rateDate: normalizedDate,
                  )
                  ?.rateToCdf) ??
        config.latestRateToCdf(originalCurrencyCode);

    if (sourceRate != null && sourceRate > 0) {
      return originalAmount * sourceRate;
    }

    if (CurrencyConfigEntity.normalizeCode(referenceCurrencyCode) ==
            CurrencyConfigEntity.defaultReferenceCurrencyCode &&
        convertedAmount != null) {
      return convertedAmount;
    }

    return null;
  }
}
