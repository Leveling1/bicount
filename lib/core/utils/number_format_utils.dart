import 'package:intl/intl.dart';

class NumberFormatUtils {
  static String formatCurrency(
    num value, {
    String? locale,
    String currencyCode = 'USD',
  }) {
    final symbol = currencyCode == 'USD' ? '\$' : 'Fc';
    final formatter = NumberFormat.currency(
      locale: locale ?? _resolvedLocale(),
      name: currencyCode,
      symbol: '',
    );
    final formattedNumber = formatter.format(value);
    return '$formattedNumber $symbol';
  }

  static String formatTransactionAmount(
    num value, {
    String? locale,
    String currencyCode = 'USD',
  }) {
    final formatted = formatCurrency(
      value.abs(),
      locale: locale,
      currencyCode: currencyCode,
    );
    final sign = value < 0 ? '-' : '+';
    return '$sign $formatted';
  }

  static String compactCurrency(
    num value, {
    String? locale,
    String currencyCode = 'USD',
  }) {
    final symbol = currencyCode == 'USD' ? '\$' : 'Fc';
    final formatter = NumberFormat.compactCurrency(
      locale: locale ?? _resolvedLocale(),
      symbol: '',
      decimalDigits: 0,
    );
    return '${formatter.format(value)}$symbol';
  }

  static String _resolvedLocale() {
    final locale = Intl.getCurrentLocale();
    if (locale.isEmpty || locale == 'und') {
      return 'en';
    }
    return locale;
  }
}
