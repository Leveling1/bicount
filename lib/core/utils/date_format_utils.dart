import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', _resolvedLocale()).format(date);
}

String formatDateSmall(DateTime date) {
  return DateFormat('MMM yyyy', _resolvedLocale()).format(date);
}

String formatedDate(DateTime date) {
  return DateFormat('EEEE, dd MMMM yyyy', _resolvedLocale()).format(date);
}

String formatedTime(DateTime date) {
  return DateFormat('HH:mm', _resolvedLocale()).format(date);
}

String formatedDateTime(DateTime date) {
  return DateFormat(
    'EEEE, dd MMMM yyyy - HH:mm',
    _resolvedLocale(),
  ).format(date);
}

String formatedDateTimeNumeric(DateTime date) {
  return DateFormat('dd/MM/yy', _resolvedLocale()).format(date);
}

String formatedDateTimeNumericFullYear(DateTime date) {
  return DateFormat('dd/MM/yyyy', _resolvedLocale()).format(date);
}

String formatDateWithoutYear(DateTime date) {
  return DateFormat('dd MMMM', _resolvedLocale()).format(date);
}

String _resolvedLocale() {
  final locale = Intl.getCurrentLocale();
  if (locale.isEmpty || locale == 'und') {
    return 'en';
  }
  return locale;
}
