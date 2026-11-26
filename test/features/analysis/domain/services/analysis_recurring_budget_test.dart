import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_budget.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_plan_pause.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final month = DateTime(2026, 11);
  final config = CurrencyConfigEntity.fallback().copyWith(
    referenceCurrencyCode: 'USD',
  );

  test('sums the real occurrences of the month and skips a pause', () {
    final salary = _plan(
      'Salary',
      1000,
      TransactionTypes.salaryCode,
      Frequency.monthly,
    );
    final charge =
        _plan(
          'Weekly charge',
          100,
          TransactionTypes.subscriptionCode,
          Frequency.weekly,
        ).withPauses([
          RecurringPlanPause(
            id: 'pause',
            planId: 'charge',
            pausedAt: DateTime(2026, 11, 8),
            pausedOn: '2026-11-08',
            resumedAt: DateTime(2026, 11, 20),
            resumedOn: '2026-11-20',
          ),
        ]);
    final annual = _plan(
      'Annual charge',
      45,
      TransactionTypes.subscriptionCode,
      Frequency.yearly,
    );
    final plans = [salary, charge, annual];
    final november = AnalysisRecurringBudget.fromAgenda(
      _agenda(month, plans),
      config,
    )!;
    expect(november.income, 1000);
    expect(november.totalCharges, 345);
    expect(november.charges.map((charge) => charge.amount), [300, 45]);

    final december = AnalysisRecurringBudget.fromAgenda(
      _agenda(DateTime(2026, 12), plans),
      config,
    )!;
    expect(december.charges.map((charge) => charge.title), ['Weekly charge']);
    expect(
      AnalysisRecurringBudget.fromAgenda(_agenda(month, [salary]), config),
      isNull,
    );
    expect(
      AnalysisRecurringBudget.fromAgenda(_agenda(month, [charge]), config),
      isNull,
    );
  });

  test(
    'converts mixed currencies and withholds the balance when a rate is missing',
    () {
      final salary = _plan(
        'Salary',
        1000,
        TransactionTypes.salaryCode,
        Frequency.monthly,
      );
      final charge = _plan(
        'Rent',
        12000,
        TransactionTypes.subscriptionCode,
        Frequency.monthly,
        currency: 'CDF',
      );
      final entries = _agenda(month, [salary, charge]);
      expect(
        AnalysisRecurringBudget.fromAgenda(entries, config)!.income,
        isNull,
      );

      final converted = AnalysisRecurringBudget.fromAgenda(
        entries,
        config.withSnapshotUpserts([
          const ExchangeRateSnapshotEntity(
            currencyCode: 'USD',
            rateDate: '2026-11-01',
            rateToCdf: 2400,
          ),
        ]),
      )!;
      expect(converted.income, 1000);
      expect(converted.totalCharges, 5);
      expect(converted.charges.single.originalAmount, 12000);
      expect(converted.charges.single.currency, 'CDF');
    },
  );
}

Iterable<AnalysisRecurringEntry> _agenda(
  DateTime month,
  List<RecurringTransfertModel> plans,
) => const AnalysisRecurringAgenda()
    .forMonth(month, plans)
    .values
    .expand((day) => day);

RecurringTransfertModel _plan(
  String title,
  double amount,
  int type,
  int frequency, {
  String currency = 'USD',
}) => RecurringTransfertModel(
  uid: 'owner',
  recurringTransfertTypeId: type,
  title: title,
  amount: amount,
  currency: currency,
  senderId: 'owner',
  beneficiaryId: 'contact',
  frequency: frequency,
  startDate: '2026-11-01',
  nextDueDate: '2026-11-01',
);
