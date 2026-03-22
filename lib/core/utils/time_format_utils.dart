import 'package:intl/intl.dart';

class TimeFormatUtils {
  static String formatHour(DateTime date, {String? locale}) {
    final format = DateFormat.jm(locale ?? _resolvedLocale());
    return format.format(date);
  }

  static String formatDay(DateTime date, {String? locale}) {
    final format = DateFormat.yMMMMd(locale ?? _resolvedLocale());
    return format.format(date);
  }

  static String formatDayAndHour(DateTime date, {String? locale}) {
    final resolvedLocale = locale ?? _resolvedLocale();
    final day = formatDay(date, locale: resolvedLocale);
    final hour = formatHour(date, locale: resolvedLocale);
    if (resolvedLocale.startsWith('fr')) {
      return '$day à $hour';
    }
    return '$day at $hour';
  }

  static String _resolvedLocale() {
    final locale = Intl.getCurrentLocale();
    if (locale.isEmpty || locale == 'und') {
      return 'en';
    }
    return locale;
  }
}
