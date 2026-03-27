import 'package:intl/intl.dart';

DateTime? parseFormDate(String rawDate) {
  final value = rawDate.trim();
  if (value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value)?.toLocal() ??
      DateFormat('dd/MM/yy').tryParseStrict(value) ??
      DateFormat('dd/MM/yyyy').tryParseStrict(value);
}

DateTime mergeDateWithReferenceTime(
  DateTime date, {
  DateTime? reference,
}) {
  final source = reference ?? DateTime.now();
  return DateTime(
    date.year,
    date.month,
    date.day,
    source.hour,
    source.minute,
    source.second,
    source.millisecond,
    source.microsecond,
  );
}

String resolveFormDateToIso(
  String rawDate, {
  DateTime? reference,
}) {
  final source = reference ?? DateTime.now();
  final parsedDate = parseFormDate(rawDate);
  if (parsedDate == null) {
    return source.toIso8601String();
  }

  final hasExplicitTime = rawDate.contains(':') || rawDate.contains('T');
  final resolvedDate = hasExplicitTime
      ? parsedDate
      : mergeDateWithReferenceTime(parsedDate, reference: source);
  return resolvedDate.toIso8601String();
}
