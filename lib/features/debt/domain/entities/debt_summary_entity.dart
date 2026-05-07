import 'package:bicount/features/debt/data/models/debt.model.dart';

class DebtSummaryEntity {
  const DebtSummaryEntity({
    required this.debt,
    required this.counterpartyName,
    required this.isReceivable,
    required this.canRecordPayment,
    required this.canManageContract,
    required this.dueDate,
    required this.isOverdue,
  });

  final DebtModel debt;
  final String counterpartyName;
  final bool isReceivable;
  final bool canRecordPayment;
  final bool canManageContract;
  final DateTime? dueDate;
  final bool isOverdue;
}
