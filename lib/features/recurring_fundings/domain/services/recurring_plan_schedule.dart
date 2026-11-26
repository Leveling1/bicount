import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';

class RecurringPlanSchedule {
  const RecurringPlanSchedule({
    this.scheduleService = const RecurringFundingScheduleService(),
  });

  final RecurringFundingScheduleService scheduleService;

  DateTime? firstOnOrAfter(RecurringTransfertModel plan, DateTime date) =>
      occurrences(plan, from: date).firstOrNull;

  Iterable<DateTime> occurrences(
    RecurringTransfertModel plan, {
    required DateTime from,
    DateTime? through,
  }) sync* {
    if (!plan.hasSchedule || plan.awaitingPauseHistory) {
      return;
    }
    final start = scheduleService.parseDate(plan.startDate);
    if (start == null) return;

    final end = scheduleService.parseDate(plan.endDate);
    final endDay = end == null ? null : scheduleService.startOfDay(end);
    final first = scheduleService.startOfDay(from);
    final last = through == null ? null : scheduleService.startOfDay(through);
    final frequency = effectiveFrequency(plan.frequency);
    var cursor = scheduleService.startOfDay(start);

    for (final pause in plan.pauses) {
      final pausedOn = DateTime.parse(pause.pausedOn);
      while (cursor.isBefore(pausedOn)) {
        if ((last != null && cursor.isAfter(last)) ||
            (endDay != null && cursor.isAfter(endDay))) {
          return;
        }
        if (!cursor.isBefore(first)) yield cursor;
        final next = _next(cursor, frequency);
        if (!next.isAfter(cursor)) return;
        cursor = next;
      }
      final resumedOn = pause.resumedOn;
      if (resumedOn == null) return;
      final override = pause.nextDueDateOverride;
      if (override != null) {
        cursor = DateTime.parse(override);
      } else {
        final resumedDay = DateTime.parse(resumedOn);
        while (cursor.isBefore(resumedDay)) {
          final next = _next(cursor, frequency);
          if (!next.isAfter(cursor)) return;
          cursor = next;
        }
      }
    }

    while ((last == null || !cursor.isAfter(last)) &&
        (endDay == null || !cursor.isAfter(endDay))) {
      if (!cursor.isBefore(first)) yield cursor;
      final next = _next(cursor, frequency);
      if (!next.isAfter(cursor)) return;
      cursor = next;
    }
  }

  DateTime _next(DateTime date, int frequency) {
    final months = switch (frequency) {
      Frequency.monthly => 1,
      Frequency.quarterly => 3,
      Frequency.yearly => 12,
      _ => 0,
    };
    if (months == 0) return scheduleService.nextOccurrence(date, frequency);
    final lastDay = DateTime(date.year, date.month + months + 1, 0);
    return DateTime(
      lastDay.year,
      lastDay.month,
      date.day > lastDay.day ? lastDay.day : date.day,
    );
  }

  static int effectiveFrequency(int frequency) => switch (frequency) {
    4 => Frequency.quarterly,
    5 => Frequency.yearly,
    _ => frequency,
  };
}

bool canConfirmRecurringDate(RecurringTransfertModel plan, DateTime date) =>
    !plan.isPaused &&
    const RecurringPlanSchedule()
        .occurrences(plan, from: date, through: date)
        .isNotEmpty;
