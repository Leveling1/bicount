import 'package:bicount/core/utils/date_format_utils.dart';

String getNextMonthSameDay(String dateString) {
  DateTime date = DateTime.parse(dateString);
  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;
  final day = date.day;

  // Check if the day has already passed this month
  if (now.day > day || (now.day == day && now.hour > date.hour)) {
    // Return same day next month
    final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;

    String formattedNextDateTime = formatDateWithoutYear(
      DateTime(nextYear, nextMonth, day),
    );
    return formattedNextDateTime;
  }

  // Return same day this month
  String formattedDateTime = formatDateWithoutYear(
    DateTime(currentYear, currentMonth, day),
  );
  return formattedDateTime;
}
