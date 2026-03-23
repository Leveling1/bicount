import 'package:bicount/core/constants/constants.dart';

class AddAccountFundingEntity {
  final String source;
  final String? note;
  final double amount;
  final String currency;
  final String date;
  final int category;
  final String? sid;

  AddAccountFundingEntity({
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
    required this.date,
    this.category = Constants.personal,
    this.sid,
  });
}
