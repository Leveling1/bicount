import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_plan_pause.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const schedule = RecurringPlanSchedule();

  test('a second pause preserves the history of the first pause', () {
    final plan = _plan([
      _pause('2026-11-08', end: '2026-11-20'),
      _pause('2026-11-23', end: '2026-12-02', override: '2026-12-05'),
      _pause('2026-12-14'),
    ]);

    expect(plan.isPaused, isTrue);
    expect(schedule.occurrences(plan, from: DateTime(2026, 11, 1)).toList(), [
      DateTime(2026, 11, 1),
      DateTime(2026, 11, 22),
      DateTime(2026, 12, 5),
      DateTime(2026, 12, 12),
    ]);
    expect(schedule.firstOnOrAfter(plan, DateTime(2026, 12, 14)), isNull);
  });

  test('keeping the cadence skips the gap and keeps the resumption day', () {
    final plan = _plan([_pause('2026-11-08', end: '2026-11-15')]);

    expect(canConfirmRecurringDate(plan, DateTime(2026, 11, 8)), isFalse);
    expect(canConfirmRecurringDate(plan, DateTime(2026, 11, 15)), isTrue);
    expect(
      schedule.firstOnOrAfter(plan, DateTime(2026, 11, 8)),
      DateTime(2026, 11, 15),
    );
  });

  test('a new recurring date respects SQL month ends', () {
    final plan = _plan([
      _pause('2026-11-08', end: '2026-11-20', override: '2027-01-31'),
    ], frequency: Frequency.monthly);

    expect(
      schedule.occurrences(
        plan,
        from: DateTime(2027, 1),
        through: DateTime(2027, 3, 31),
      ),
      [DateTime(2027, 1, 31), DateTime(2027, 2, 28), DateTime(2027, 3, 28)],
    );
  });

  test('a later resumption can advance a previously deferred first date', () {
    final plan = _plan([
      _pause('2026-11-08', end: '2026-11-10', override: '2026-12-01'),
      _pause('2026-11-13', end: '2026-11-15', override: '2026-11-20'),
    ]);
    expect(canConfirmRecurringDate(plan, DateTime(2026, 11, 20)), isTrue);
    expect(
      schedule.firstOnOrAfter(plan, DateTime(2026, 11, 10)),
      DateTime(2026, 11, 20),
    );
  });
}

RecurringTransfertModel _plan(
  List<RecurringPlanPause> pauses, {
  int frequency = Frequency.weekly,
}) => RecurringTransfertModel(
  uid: 'user',
  recurringTransfertTypeId: 3,
  title: 'Rent',
  amount: 50,
  currency: 'USD',
  senderId: 'user',
  beneficiaryId: 'contact',
  frequency: frequency,
  startDate: '2026-11-01',
  nextDueDate: '2026-11-01',
  pauses: pauses,
);

RecurringPlanPause _pause(String start, {String? end, String? override}) =>
    RecurringPlanPause(
      id: start,
      planId: 'plan',
      pausedAt: DateTime.parse(start),
      pausedOn: start,
      resumedAt: end == null ? null : DateTime.parse(end),
      resumedOn: end,
      nextDueDateOverride: override,
    );
