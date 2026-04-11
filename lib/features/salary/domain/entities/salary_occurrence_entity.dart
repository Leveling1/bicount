import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

class SalaryOccurrenceEntity extends Equatable {
  const SalaryOccurrenceEntity({
    required this.occurrenceId,
    required this.recurringTransfert,
    required this.expectedDate,
    required this.state,
    required this.referenceAmount,
    this.receivedTransaction,
  });

  final String occurrenceId;
  final RecurringTransfertModel recurringTransfert;
  final TransactionModel? receivedTransaction;
  final DateTime expectedDate;
  final int state;
  final double referenceAmount;

  double get amount => receivedTransaction?.amount ?? recurringTransfert.amount;
  String get currency =>
      receivedTransaction?.currency ?? recurringTransfert.currency;
  String get source => recurringTransfert.title;
  String? get note => receivedTransaction?.note ?? recurringTransfert.note;
  DateTime? get receivedDate =>
      DateTime.tryParse(receivedTransaction?.date ?? '');
  bool get isReceived => state == AppSalaryOccurrenceState.received;
  bool get needsAttention => AppSalaryOccurrenceState.needsAttention(state);
  bool get isOverdue => state == AppSalaryOccurrenceState.overdue;
  bool get isDueToday => state == AppSalaryOccurrenceState.dueToday;
  bool get isUpcoming => state == AppSalaryOccurrenceState.upcoming;
  bool get requiresConfirmation =>
      recurringTransfert.recurringTransfertTypeId ==
          TransactionTypes.salaryCode &&
      AppExecutionMode.requiresConfirmation(recurringTransfert.executionMode);
  bool get remindersEnabled => recurringTransfert.reminderEnabled;

  @override
  List<Object?> get props => [
    occurrenceId,
    recurringTransfert,
    receivedTransaction,
    expectedDate,
    state,
    referenceAmount,
  ];
}
