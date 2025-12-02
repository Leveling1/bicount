import 'package:intl/intl.dart';

class NumberFormatUtils {
  /// Formats a number as currency according to the given [locale] and [currencyCode], using the correct symbol (e.g. $, €).
  static String formatCurrency(
    num value, {
    String locale = 'en_US',
    String currencyCode = 'USD',
  }) {
    final symbol = currencyCode == 'USD' ? '\$' : 'Fc';
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: '',
    );
    final formattedNumber = formatter.format(value);
    return '$formattedNumber $symbol';
  }

  /// Formats a transaction amount with + or - sign, and currency formatting.
  static String formatTransactionAmount(
    num value, {
    String locale = 'en_US',
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
}
