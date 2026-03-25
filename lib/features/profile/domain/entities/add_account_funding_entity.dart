import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/account_funding_const.dart';

class AddAccountFundingEntity {
  final String source;
  final String? note;
  final double amount;
  final String currency;
  final String date;
  final int category;
  final String? sid;
  final int fundingType;
  final bool isRecurring;
  final int? frequency;

  AddAccountFundingEntity({
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
    required this.date,
    this.category = Constants.personal,
    this.sid,
    this.fundingType = AccountFundingType.other,
    this.isRecurring = false,
    this.frequency,
  });
}
