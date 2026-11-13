import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/account_funding_const.dart';

class AccountFundingModel extends OfflineModel {
  final String fundingId;

  final String sid;

  final double amount;

  final String currency;
  final String? walletId;

  final String? referenceCurrencyCode;

  final double? convertedAmount;

  final double? amountCdf;

  final double? rateToCdf;

  final String? fxRateDate;

  final String? fxSnapshotId;

  final int category;

  final int fundingType;

  final String source;

  final String? note;

  final String date;

  final String? createdAt;

  AccountFundingModel({
    String? fundingId,
    required this.sid,
    required this.amount,
    required this.currency,
    this.walletId,
    this.referenceCurrencyCode,
    this.convertedAmount,
    this.amountCdf,
    this.rateToCdf,
    this.fxRateDate,
    this.fxSnapshotId,
    required this.category,
    this.fundingType = AccountFundingType.other,
    required this.source,
    required this.date,
    this.note,
    this.createdAt,
  }) : fundingId = fundingId ?? const Uuid().v4(),
       super();
}
