import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:intl/intl.dart';

class NumberFormatUtils {
  static Map<String, AppCurrencyEntity> _currenciesByCode = {
    for (final currency in AppCurrencyEntity.fallbackCurrencies)
      currency.code: currency,
  };
  static String _defaultCurrencyCode = 'CDF';

  static void configureCurrencies({
    required List<AppCurrencyEntity> currencies,
    required String defaultCurrencyCode,
  }) {
    if (currencies.isNotEmpty) {
      _currenciesByCode = {
        for (final currency in currencies) currency.code: currency,
      };
    }
    _defaultCurrencyCode = defaultCurrencyCode.toUpperCase();
  }

  static String formatCurrency(
    num value, {
    String? locale,
    String? currencyCode,
  }) {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);
    final currency = _currenciesByCode[normalizedCode];
    final formatted = _formatGroupedNumber(
      value,
      locale: locale,
      decimals: currency?.decimals ?? 2,
    );
    return '$formatted ${currency?.symbol ?? normalizedCode}'.trim();
  }

  static String formatTransactionAmount(
    num value, {
    String? locale,
    String? currencyCode,
  }) {
    final sign = value < 0 ? '-' : '+';
    return '$sign ${formatCurrency(value.abs(), locale: locale, currencyCode: currencyCode)}';
  }

  static String compactCurrency(
    num value, {
    String? locale,
    String? currencyCode,
  }) {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);
    final currency = _currenciesByCode[normalizedCode];
    final formatted = _formatCompactNumber(
      value,
      locale: locale,
      decimals: currency?.decimals ?? 2,
    );
    return '$formatted ${currency?.symbol ?? normalizedCode}'.trim();
  }

  static String resolveSymbol(String? currencyCode) {
    final normalizedCode = _normalizeCurrencyCode(currencyCode);
    return _currenciesByCode[normalizedCode]?.symbol ?? normalizedCode;
  }

  static String _normalizeCurrencyCode(String? value) {
    final normalized = (value ?? _defaultCurrencyCode).trim().toUpperCase();
    return normalized.isEmpty ? _defaultCurrencyCode : normalized;
  }

  static String _formatGroupedNumber(
    num value, {
    required int decimals,
    String? locale,
  }) {
    final localeCode = locale ?? _resolvedLocale();
    final absoluteValue = value.abs();
    final formatter = NumberFormat.decimalPattern(localeCode)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = absoluteValue == absoluteValue.roundToDouble()
          ? 0
          : decimals.clamp(0, 4);

    final symbols = formatter.symbols;
    return formatter
        .format(value)
        .replaceAll(symbols.GROUP_SEP, ' ')
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u202F', ' ');
  }

  static String _formatCompactNumber(
    num value, {
    required int decimals,
    String? locale,
  }) {
    final absoluteValue = value.abs();
    if (absoluteValue < 100000) {
      return _formatGroupedNumber(value, decimals: decimals, locale: locale);
    }

    const units = <({double divisor, String suffix})>[
      (divisor: 1000000000, suffix: 'B'),
      (divisor: 1000000, suffix: 'M'),
      (divisor: 1000, suffix: 'K'),
    ];

    final localeCode = locale ?? _resolvedLocale();
    for (final unit in units) {
      if (absoluteValue >= unit.divisor) {
        final compactValue = value / unit.divisor;
        final formatter = NumberFormat.decimalPattern(localeCode)
          ..minimumFractionDigits = 0
          ..maximumFractionDigits =
              compactValue.abs() >= 100 ||
                  compactValue == compactValue.roundToDouble()
              ? 0
              : 1;
        final symbols = formatter.symbols;
        final number = formatter
            .format(compactValue)
            .replaceAll(symbols.GROUP_SEP, ' ')
            .replaceAll('\u00A0', ' ')
            .replaceAll('\u202F', ' ');
        return '$number ${unit.suffix}';
      }
    }

    return _formatGroupedNumber(value, decimals: decimals, locale: locale);
  }

  static String _resolvedLocale() {
    final locale = Intl.getCurrentLocale();
    if (locale.isEmpty || locale == 'und') {
      return 'en';
    }
    return locale;
  }
}
