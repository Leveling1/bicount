import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';
import 'recurring_plan_pause.dart';

class RecurringTransfertModel extends OfflineModel {
  final String? recurringTransfertId;

  final String uid;

  final int recurringTransfertTypeId;

  final String title;

  final String note;

  final double amount;

  final String currency;

  final String senderId;
  final String? senderWalletId;

  final String beneficiaryId;
  final String? beneficiaryWalletId;

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
  final List<RecurringPlanPause> pauses;

  bool get hasOpenPause => pauses.any((pause) => pause.isOpen);
  bool get awaitingPauseHistory =>
      status == AppRecurringTransfertState.paused && pauses.isEmpty;
  bool get isPaused => hasOpenPause || awaitingPauseHistory;
  bool get hasSchedule =>
      AppRecurringTransfertState.isActive(status) ||
      status == AppRecurringTransfertState.paused;

  RecurringTransfertModel({
    String? recurringTransfertId,
    required this.uid,
    required this.recurringTransfertTypeId,
    required this.title,
    this.note = '',
    required this.amount,
    required this.currency,
    required this.senderId,
    this.senderWalletId,
    required this.beneficiaryId,
    this.beneficiaryWalletId,
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
    this.pauses = const [],
  }) : recurringTransfertId = recurringTransfertId ?? const Uuid().v4(),
       super();

  RecurringTransfertModel withPauses(List<RecurringPlanPause> history) =>
      RecurringTransfertModel(
        recurringTransfertId: recurringTransfertId,
        uid: uid,
        recurringTransfertTypeId: recurringTransfertTypeId,
        title: title,
        note: note,
        amount: amount,
        currency: currency,
        senderId: senderId,
        senderWalletId: senderWalletId,
        beneficiaryId: beneficiaryId,
        beneficiaryWalletId: beneficiaryWalletId,
        frequency: frequency,
        startDate: startDate,
        nextDueDate: nextDueDate,
        endDate: endDate,
        status: status,
        executionMode: executionMode,
        reminderEnabled: reminderEnabled,
        lastGeneratedAt: lastGeneratedAt,
        lastConfirmedAt: lastConfirmedAt,
        createdAt: createdAt,
        pauses: List.unmodifiable(history),
      );
}
