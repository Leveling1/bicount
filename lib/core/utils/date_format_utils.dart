import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat("dd MMMM yyyy", 'en_EN').format(date);
}

String formatDateSmall(DateTime date) {
  return DateFormat("MMM yyyy", 'en_EN').format(date);
}

String formatedDate(DateTime date) {
  return DateFormat('EEEE, dd MMMM yyyy', 'en_EN').format(date);
}

String formatedTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

String formatedDateTime(DateTime date) {
  return DateFormat('EEEE, dd MMMM yyyy - HH:mm').format(date);
}

String formatedDateTimeNumeric(DateTime date) {
  return DateFormat('dd/MM/yy').format(date);
}

String formatedDateTimeNumericFullYear(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDateWithoutYear(DateTime date) {
  return DateFormat("dd MMMM", 'en_EN').format(date);
}
