import 'package:bicount/core/offline/offline_model.dart';

class RecurringPlanPause extends OfflineModel {
  RecurringPlanPause({
    required this.id,
    required this.planId,
    required this.pausedAt,
    required this.pausedOn,
    this.resumedAt,
    this.resumedOn,
    this.nextDueDateOverride,
  });

  final String id;
  final String planId;
  final DateTime pausedAt;
  final String pausedOn;
  final DateTime? resumedAt;
  final String? resumedOn;
  final String? nextDueDateOverride;

  bool get isOpen => resumedAt == null;

  factory RecurringPlanPause.fromRow(Map<String, dynamic> row) {
    final resumedAt = row['resumed_at'] as String?;
    return RecurringPlanPause(
      id: row['pause_id'] as String,
      planId: row['recurring_transfert_id'] as String,
      pausedAt: DateTime.parse(row['paused_at'] as String),
      pausedOn: row['paused_on'] as String,
      resumedAt: resumedAt == null ? null : DateTime.parse(resumedAt),
      resumedOn: row['resumed_on'] as String?,
      nextDueDateOverride: row['next_due_date_override'] as String?,
    );
  }

  Map<String, dynamic> toRow() => {
    'pause_id': id,
    'recurring_transfert_id': planId,
    'paused_at': pausedAt.toUtc().toIso8601String(),
    'paused_on': pausedOn,
    'resumed_at': resumedAt?.toUtc().toIso8601String(),
    'resumed_on': resumedOn,
    'next_due_date_override': nextDueDateOverride,
  };
}
