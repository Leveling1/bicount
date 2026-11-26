import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_schedule.dart';

typedef AnalysisRecurringEntry = ({
  RecurringTransfertModel plan,
  RecurringPlanScope scope,
});

class AnalysisRecurringAgenda {
  const AnalysisRecurringAgenda({
    this.schedule = const RecurringPlanSchedule(),
  });

  final RecurringPlanSchedule schedule;

  Map<DateTime, List<AnalysisRecurringEntry>> forMonth(
    DateTime month,
    Iterable<RecurringTransfertModel> plans,
  ) {
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime, List<AnalysisRecurringEntry>>{};

    for (final plan in plans) {
      final scope = RecurringPlanScope.values
          .where((scope) => scope.matchesType(plan.recurringTransfertTypeId))
          .firstOrNull;
      if (scope == null) continue;

      for (final date in schedule.occurrences(
        plan,
        from: first,
        through: last,
      )) {
        (days[date] ??= []).add((plan: plan, scope: scope));
      }
    }
    for (final entries in days.values) {
      entries.sort((left, right) {
        final scope = right.scope.index.compareTo(left.scope.index);
        return scope == 0 ? left.plan.title.compareTo(right.plan.title) : scope;
      });
    }
    return days;
  }
}
