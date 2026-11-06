import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class DebtModel extends OfflineModel {
  final String? debtId;

  final String createdBy;

  final String lenderId;

  final String borrowerId;

  final String principalTransactionId;

  final String title;

  final String note;

  final String currency;

  final double principalAmount;

  final double expectedRepaymentAmount;

  final String? expectedRepaymentCurrency;

  final double repaidAmount;

  final double remainingAmount;

  final String dueDate;

  final int status;

  final bool reminderEnabled;

  final String? lastDueNotificationAt;

  final String? closedAt;

  final String? createdAt;

  final String? updatedAt;

  DebtModel({
    String? debtId,
    required this.createdBy,
    required this.lenderId,
    required this.borrowerId,
    required this.principalTransactionId,
    required this.title,
    this.note = '',
    required this.currency,
    required this.principalAmount,
    required this.expectedRepaymentAmount,
    this.expectedRepaymentCurrency,
    this.repaidAmount = 0,
    required this.remainingAmount,
    required this.dueDate,
    this.status = 0,
    this.reminderEnabled = true,
    this.lastDueNotificationAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  }) : debtId = debtId ?? const Uuid().v4(),
       super();
}
