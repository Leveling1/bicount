import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class SubscriptionModel extends OfflineModel {
  final String? subscriptionId;

  final String sid;

  final String title;

  final double amount;

  final String currency;

  final String? referenceCurrencyCode;

  final double? convertedAmount;

  final double? amountCdf;

  final double? rateToCdf;

  final String? fxRateDate;

  final String? fxSnapshotId;

  final int frequency;

  final String startDate;

  final String nextBillingDate;

  final String? endDate;

  final String? notes;

  final String? createdAt;

  final int? category;

  final int? status;

  SubscriptionModel({
    String? subscriptionId,
    required this.sid,
    required this.title,
    required this.amount,
    required this.currency,
    this.referenceCurrencyCode,
    this.convertedAmount,
    this.amountCdf,
    this.rateToCdf,
    this.fxRateDate,
    this.fxSnapshotId,
    required this.frequency,
    required this.startDate,
    required this.nextBillingDate,
    this.endDate,
    this.notes,
    this.createdAt,
    this.category,
    this.status,
  }) : subscriptionId = subscriptionId ?? const Uuid().v4(),
       super();
}
