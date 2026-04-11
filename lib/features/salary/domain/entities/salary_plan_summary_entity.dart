import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:equatable/equatable.dart';

class SalaryPlanSummaryEntity extends Equatable {
  const SalaryPlanSummaryEntity({
    required this.recurringTransfert,
    required this.nextExpectedDate,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.outstandingReferenceAmount,
  });

  final RecurringTransfertModel recurringTransfert;
  final DateTime? nextExpectedDate;
  final int overdueCount;
  final int dueTodayCount;
  final double outstandingReferenceAmount;

  bool get requiresConfirmation =>
      AppExecutionMode.requiresConfirmation(recurringTransfert.executionMode);

  bool get remindersEnabled => recurringTransfert.reminderEnabled;

  int get totalAttentionCount => overdueCount + dueTodayCount;

  @override
  List<Object?> get props => [
    recurringTransfert,
    nextExpectedDate,
    overdueCount,
    dueTodayCount,
    outstandingReferenceAmount,
  ];
}
