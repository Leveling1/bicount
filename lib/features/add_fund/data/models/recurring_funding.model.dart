import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:uuid/uuid.dart';

class RecurringFundingModel extends OfflineModel {
  final String recurringFundingId;

  final String uid;

  final String source;

  final String? note;

  final double amount;

  final String currency;

  final int fundingType;

  final int frequency;

  final String startDate;

  final String nextFundingDate;

  final String? lastProcessedAt;

  final int status;

  final int salaryProcessingMode;

  final int salaryReminderStatus;

  final String? createdAt;

  RecurringFundingModel({
    String? recurringFundingId,
    required this.uid,
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
    this.fundingType = AccountFundingType.other,
    required this.frequency,
    required this.startDate,
    required this.nextFundingDate,
    this.lastProcessedAt,
    this.status = RecurringFundingStatus.active,
    this.salaryProcessingMode = SalaryProcessingMode.automatic,
    this.salaryReminderStatus = SalaryReminderStatus.enabled,
    this.createdAt,
  }) : recurringFundingId = recurringFundingId ?? const Uuid().v4(),
       super();
}
