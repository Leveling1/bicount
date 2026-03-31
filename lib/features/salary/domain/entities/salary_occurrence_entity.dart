import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:equatable/equatable.dart';

class SalaryOccurrenceEntity extends Equatable {
  const SalaryOccurrenceEntity({
    required this.occurrenceId,
    required this.recurringFunding,
    required this.expectedDate,
    required this.state,
    required this.referenceAmount,
    this.receivedFunding,
  });

  final String occurrenceId;
  final RecurringFundingModel recurringFunding;
  final AccountFundingModel? receivedFunding;
  final DateTime expectedDate;
  final int state;
  final double referenceAmount;

  double get amount => receivedFunding?.amount ?? recurringFunding.amount;
  String get currency => receivedFunding?.currency ?? recurringFunding.currency;
  String get source => receivedFunding?.source ?? recurringFunding.source;
  String? get note => receivedFunding?.note ?? recurringFunding.note;
  DateTime? get receivedDate => DateTime.tryParse(receivedFunding?.date ?? '');
  bool get isReceived => state == AppSalaryOccurrenceState.received;
  bool get needsAttention => AppSalaryOccurrenceState.needsAttention(state);
  bool get isOverdue => state == AppSalaryOccurrenceState.overdue;
  bool get isDueToday => state == AppSalaryOccurrenceState.dueToday;
  bool get isUpcoming => state == AppSalaryOccurrenceState.upcoming;
  bool get requiresConfirmation =>
      recurringFunding.fundingType == AccountFundingType.salary &&
      SalaryProcessingMode.requiresConfirmation(
        recurringFunding.salaryProcessingMode,
      );
  bool get remindersEnabled =>
      SalaryReminderStatus.isEnabled(recurringFunding.salaryReminderStatus);

  @override
  List<Object?> get props => [
    occurrenceId,
    recurringFunding,
    receivedFunding,
    expectedDate,
    state,
    referenceAmount,
  ];
}
