import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:equatable/equatable.dart';

class RecurringPlanSummaryEntity extends Equatable {
  const RecurringPlanSummaryEntity({
    required this.recurringTransfert,
    required this.nextExpectedDate,
    required this.lastRecordedDate,
    required this.monthlyReferenceAmount,
    required this.totalRecordedReferenceAmount,
    required this.recordedCount,
  });

  final RecurringTransfertModel recurringTransfert;
  final DateTime? nextExpectedDate;
  final DateTime? lastRecordedDate;
  final double monthlyReferenceAmount;
  final double totalRecordedReferenceAmount;
  final int recordedCount;

  bool get isActive =>
      AppRecurringTransfertState.isActive(recurringTransfert.status);
  bool get isAutomatic =>
      AppExecutionMode.isAutomatic(recurringTransfert.executionMode);
  bool get requiresConfirmation =>
      AppExecutionMode.requiresConfirmation(recurringTransfert.executionMode);

  @override
  List<Object?> get props => [
    recurringTransfert,
    nextExpectedDate,
    lastRecordedDate,
    monthlyReferenceAmount,
    totalRecordedReferenceAmount,
    recordedCount,
  ];
}
