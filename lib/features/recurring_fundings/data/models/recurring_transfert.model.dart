import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class RecurringTransfertModel extends OfflineModel {
  final String? recurringTransfertId;

  final String uid;

  final int recurringTransfertTypeId;

  final String title;

  final String note;

  final double amount;

  final String currency;

  final String senderId;

  final String beneficiaryId;

  final int frequency;

  final String startDate;

  final String nextDueDate;

  final String? endDate;

  final int status;

  final int executionMode;

  final bool reminderEnabled;

  final String? lastGeneratedAt;

  final String? lastConfirmedAt;

  final String? createdAt;

  RecurringTransfertModel({
    String? recurringTransfertId,
    required this.uid,
    required this.recurringTransfertTypeId,
    required this.title,
    this.note = '',
    required this.amount,
    required this.currency,
    required this.senderId,
    required this.beneficiaryId,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.endDate,
    this.status = 0,
    this.executionMode = 0,
    this.reminderEnabled = true,
    this.lastGeneratedAt,
    this.lastConfirmedAt,
    this.createdAt,
  }) : recurringTransfertId = recurringTransfertId ?? const Uuid().v4(),
       super();
}
