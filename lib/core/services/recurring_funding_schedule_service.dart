import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:intl/intl.dart';

class RecurringFundingScheduleService {
  const RecurringFundingScheduleService();

  DateTime? parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawDate)?.toLocal() ??
        DateFormat('dd/MM/yy').tryParseStrict(rawDate) ??
        DateFormat('dd/MM/yyyy').tryParseStrict(rawDate);
  }

  String normalizeDate(String rawDate) {
    return resolveFormDateToIso(rawDate);
  }

  DateTime startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime nextOccurrence(DateTime value, int frequency) {
    switch (frequency) {
      case Frequency.weekly:
        return value.add(const Duration(days: 7));
      case Frequency.monthly:
        return DateTime(value.year, value.month + 1, value.day);
      case Frequency.quarterly:
        return DateTime(value.year, value.month + 3, value.day);
      case Frequency.yearly:
        return DateTime(value.year + 1, value.month, value.day);
      default:
        return value;
    }
  }

  String occurrenceFundingId(String recurringFundingId, DateTime value) {
    return '$recurringFundingId-${DateFormat('yyyyMMdd').format(value)}';
  }
}
