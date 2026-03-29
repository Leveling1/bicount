import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:equatable/equatable.dart';

class CurrencyConfigEntity extends Equatable {
  const CurrencyConfigEntity({
    required this.referenceCurrencyCode,
    required this.currencies,
    required this.snapshotsByKey,
  });

  static const defaultReferenceCurrencyCode = 'CDF';

  final String referenceCurrencyCode;
  final List<AppCurrencyEntity> currencies;
  final Map<String, ExchangeRateSnapshotEntity> snapshotsByKey;

  factory CurrencyConfigEntity.fallback() {
    return const CurrencyConfigEntity(
      referenceCurrencyCode: defaultReferenceCurrencyCode,
      currencies: AppCurrencyEntity.fallbackCurrencies,
      snapshotsByKey: {},
    );
  }

  CurrencyConfigEntity copyWith({
    String? referenceCurrencyCode,
    List<AppCurrencyEntity>? currencies,
    Map<String, ExchangeRateSnapshotEntity>? snapshotsByKey,
  }) {
    return CurrencyConfigEntity(
      referenceCurrencyCode:
          referenceCurrencyCode ?? this.referenceCurrencyCode,
      currencies: currencies ?? this.currencies,
      snapshotsByKey: snapshotsByKey ?? this.snapshotsByKey,
    );
  }

  CurrencyConfigEntity withSnapshotUpserts(
    Iterable<ExchangeRateSnapshotEntity> snapshots,
  ) {
    final nextSnapshots = Map<String, ExchangeRateSnapshotEntity>.from(
      snapshotsByKey,
    );
    for (final snapshot in snapshots) {
      nextSnapshots[snapshot.cacheKey] = snapshot;
    }
    return copyWith(snapshotsByKey: nextSnapshots);
  }

  List<AppCurrencyEntity> get sortedCurrencies {
    final items = [...currencies];
    items.sort(
      (left, right) => left.displayOrder.compareTo(right.displayOrder),
    );
    return items.where((item) => item.isActive).toList(growable: false);
  }

  AppCurrencyEntity currencyFor(String? code) {
    final normalizedCode = _normalizeCode(code);
    return sortedCurrencies.firstWhere(
      (item) => item.code == normalizedCode,
      orElse: () => sortedCurrencies.firstWhere(
        (item) => item.code == referenceCurrencyCode,
        orElse: () => AppCurrencyEntity.fallbackCurrencies.first,
      ),
    );
  }

  bool containsCurrency(String? code) {
    final normalizedCode = _normalizeCode(code);
    return sortedCurrencies.any((item) => item.code == normalizedCode);
  }

  ExchangeRateSnapshotEntity? snapshotFor({
    required String currencyCode,
    required String rateDate,
  }) {
    final normalizedCode = _normalizeCode(currencyCode);
    if (normalizedCode == defaultReferenceCurrencyCode) {
      return ExchangeRateSnapshotEntity.cdf(_normalizeDate(rateDate));
    }
    return snapshotsByKey['${_normalizeDate(rateDate)}|$normalizedCode'];
  }

  double? latestRateToCdf(String currencyCode) {
    return latestSnapshot(currencyCode)?.rateToCdf;
  }

  ExchangeRateSnapshotEntity? latestSnapshot(String currencyCode) {
    final normalizedCode = _normalizeCode(currencyCode);
    if (normalizedCode == defaultReferenceCurrencyCode) {
      return null;
    }

    final candidates =
        snapshotsByKey.values
            .where((snapshot) => snapshot.currencyCode == normalizedCode)
            .toList()
          ..sort((left, right) => right.rateDate.compareTo(left.rateDate));

    return candidates.isEmpty ? null : candidates.first;
  }

  Set<String> missingRateDates({
    required String currencyCode,
    required Iterable<String> rateDates,
  }) {
    final normalizedCode = _normalizeCode(currencyCode);
    if (normalizedCode == defaultReferenceCurrencyCode) {
      return {};
    }
    return {
      for (final value in rateDates)
        if (snapshotFor(currencyCode: normalizedCode, rateDate: value) == null)
          _normalizeDate(value),
    };
  }

  static String normalizeCode(String? value) => _normalizeCode(value);

  static String normalizeDate(String value) => _normalizeDate(value);

  static String _normalizeCode(String? value) {
    final resolved = (value ?? defaultReferenceCurrencyCode)
        .trim()
        .toUpperCase();
    return resolved.isEmpty ? defaultReferenceCurrencyCode : resolved;
  }

  static String _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 10) {
      return trimmed.substring(0, 10);
    }
    return trimmed;
  }

  @override
  List<Object?> get props => [
    referenceCurrencyCode,
    sortedCurrencies,
    snapshotsByKey,
  ];
}
