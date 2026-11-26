enum RecurringPlanPauseAction { pause, resume }

class RecurringPlanPauseChange {
  const RecurringPlanPauseChange(this.planId, {this.nextDueDate});

  final String planId;
  final DateTime? nextDueDate;
}
