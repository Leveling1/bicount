import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:equatable/equatable.dart';

class SalaryPlanSummaryEntity extends Equatable {
  const SalaryPlanSummaryEntity({
    required this.recurringFunding,
    required this.nextExpectedDate,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.outstandingReferenceAmount,
  });

  final RecurringFundingModel recurringFunding;
  final DateTime? nextExpectedDate;
  final int overdueCount;
  final int dueTodayCount;
  final double outstandingReferenceAmount;

  bool get requiresConfirmation => SalaryProcessingMode.requiresConfirmation(
    recurringFunding.salaryProcessingMode,
  );

  bool get remindersEnabled =>
      SalaryReminderStatus.isEnabled(recurringFunding.salaryReminderStatus);

  int get totalAttentionCount => overdueCount + dueTodayCount;

  @override
  List<Object?> get props => [
    recurringFunding,
    nextExpectedDate,
    overdueCount,
    dueTodayCount,
    outstandingReferenceAmount,
  ];
}
