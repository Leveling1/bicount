import 'package:intl/intl.dart';

class TimeFormatUtils {
  /// Format only the hour, e.g. 10:30 AM or 10:30 (24h, depending on locale)
  static String formatHour(DateTime date, {String locale = 'en_US'}) {
    final format = DateFormat.jm(locale); // jm = hour:minute with AM/PM if needed
    return format.format(date);
  }

  /// Format only the day, e.g. 12 janvier 2025 (localized)
  static String formatDay(DateTime date, {String locale = 'fr_FR'}) {
    final format = DateFormat.yMMMMd(locale); // e.g. 12 janvier 2025
    return format.format(date);
  }

  /// Format day and hour, e.g. 12 janvier 2025 à 10:30 AM (localized, with 'à' for fr)
  static String formatDayAndHour(DateTime date, {String locale = 'fr_FR'}) {
    final day = formatDay(date, locale: locale);
    final hour = formatHour(date, locale: locale);
    if (locale.startsWith('fr')) {
      return '$day à $hour';
    } else {
      return '$day at $hour';
    }
  }
}

