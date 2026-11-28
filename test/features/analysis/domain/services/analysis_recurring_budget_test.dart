import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_budget.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_plan_pause.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
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
    final november = _budget(month, plans, config)!;
    expect(november.income, 1000);
    expect(november.totalCharges, 345);
    expect(november.charges.map((charge) => charge.amount), [300, 45]);

    final december = _budget(DateTime(2026, 12), plans, config)!;
    expect(december.charges.map((charge) => charge.title), ['Weekly charge']);
    expect(_budget(month, [salary], config), isNull);
    expect(_budget(month, [charge], config), isNull);
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
      expect(_budget(month, [salary, charge], config)!.income, isNull);

      final converted = _budget(
        month,
        [salary, charge],
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

  test('replaces only the confirmed occurrence and deduplicates it', () {
    final salary = _plan(
      'Salary',
      1000,
      TransactionTypes.salaryCode,
      Frequency.weekly,
    );
    final rent = _plan(
      'Rent',
      494,
      TransactionTypes.subscriptionCode,
      Frequency.monthly,
    );
    final booking = TransactionModel(
      uid: 'owner',
      gtid: 'salary',
      name: 'Salary',
      type: TransactionTypes.salaryCode,
      beneficiaryId: 'owner',
      senderId: 'contact',
      date: '2026-12-02',
      originOccurrenceDate: '2026-11-01',
      recurringTransfertId: salary.recurringTransfertId,
      note: '',
      amount: 2280000,
      currency: 'CDF',
      referenceCurrencyCode: 'USD',
      convertedAmount: 950,
    );
    final periodBudget = AnalysisRecurringBudget.forRange(
      start: month,
      end: DateTime(2026, 11, 7),
      plans: [salary, rent],
      transactions: [booking, booking],
      config: config,
    )!;
    expect(periodBudget.receivedIncome, 950);
    expect(periodBudget.plannedIncome, isNull);
    expect(periodBudget.income! - periodBudget.totalCharges, 456);

    final monthly = _budget(
      month,
      [salary, rent],
      config,
      transactions: [booking],
    )!;
    expect(monthly.receivedIncome, 950);
    expect(monthly.plannedIncome, 4000);
  });

  test('the current month uses its civil boundaries', () {
    final now = DateTime(2028, 2, 12, 18);
    final month = AnalysisPeriod.currentMonth.resolveRange(now)!;
    final week = AnalysisPeriod.week7.resolveRange(now)!;
    expect(month.start, DateTime(2028, 2, 1));
    expect(month.end, DateTime(2028, 2, 29));
    expect(week.start, DateTime(2028, 2, 6));
    expect(week.end, DateTime(2028, 2, 12));
  });
}

AnalysisRecurringBudget? _budget(
  DateTime month,
  List<RecurringTransfertModel> plans,
  CurrencyConfigEntity config, {
  List<TransactionModel> transactions = const [],
}) => AnalysisRecurringBudget.forRange(
  start: month,
  end: DateTime(month.year, month.month + 1, 0),
  plans: plans,
  transactions: transactions,
  config: config,
);

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
