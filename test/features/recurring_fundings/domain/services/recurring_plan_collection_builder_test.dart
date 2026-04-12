import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = RecurringPlanCollectionBuilder();
  const currencyConfig = CurrencyConfigEntity(
    referenceCurrencyCode: 'CDF',
    currencies: [],
    snapshotsByKey: {},
  );

  RecurringTransfertModel plan({
    required String id,
    required int frequency,
    required double amount,
    String currency = 'CDF',
    String? startDate,
    String? nextDueDate,
  }) {
    return RecurringTransfertModel(
      recurringTransfertId: id,
      uid: 'user-1',
      recurringTransfertTypeId: TransactionTypes.subscriptionCode,
      title: 'Plan $id',
      amount: amount,
      currency: currency,
      senderId: 'user-1',
      beneficiaryId: 'friend-1',
      frequency: frequency,
      startDate: startDate ?? DateTime(2026, 4, 1).toIso8601String(),
      nextDueDate: nextDueDate ?? DateTime(2026, 4, 1).toIso8601String(),
    );
  }

  test('monthly load uses the shared Frequency constants', () {
    final collection = builder.build(
      recurringTransferts: [
        plan(id: 'weekly', frequency: Frequency.weekly, amount: 120),
        plan(id: 'monthly', frequency: Frequency.monthly, amount: 120),
        plan(id: 'quarterly', frequency: Frequency.quarterly, amount: 120),
        plan(id: 'yearly', frequency: Frequency.yearly, amount: 120),
      ],
      transactions: const [],
      currencyConfig: currencyConfig,
      scope: RecurringPlanScope.charge,
      now: DateTime(2026, 4, 1),
    );

    expect(collection.activeCount, 4);
    expect(collection.monthlyReferenceAmount, closeTo(690, 0.0001));

    final monthlyById = {
      for (final summary in collection.plans)
        summary.recurringTransfert.recurringTransfertId!:
            summary.monthlyReferenceAmount,
    };

    expect(monthlyById['weekly'], closeTo(520, 0.0001));
    expect(monthlyById['monthly'], closeTo(120, 0.0001));
    expect(monthlyById['quarterly'], closeTo(40, 0.0001));
    expect(monthlyById['yearly'], closeTo(10, 0.0001));
  });

  test('monthly load still normalizes legacy quarterly and yearly ids', () {
    final collection = builder.build(
      recurringTransferts: [
        plan(id: 'legacy-quarterly', frequency: 4, amount: 120),
        plan(id: 'legacy-yearly', frequency: 5, amount: 120),
      ],
      transactions: const [],
      currencyConfig: currencyConfig,
      scope: RecurringPlanScope.charge,
      now: DateTime(2026, 4, 1),
    );

    final monthlyById = {
      for (final summary in collection.plans)
        summary.recurringTransfert.recurringTransfertId!:
            summary.monthlyReferenceAmount,
    };

    expect(monthlyById['legacy-quarterly'], closeTo(40, 0.0001));
    expect(monthlyById['legacy-yearly'], closeTo(10, 0.0001));
  });

  test('monthly load converts each plan before summing mixed currencies', () {
    final rateDate = DateTime(2026, 4, 1).toIso8601String();
    final usdSnapshot = ExchangeRateSnapshotEntity(
      currencyCode: 'USD',
      rateDate: rateDate,
      rateToCdf: 2000,
    );
    final eurSnapshot = ExchangeRateSnapshotEntity(
      currencyCode: 'EUR',
      rateDate: rateDate,
      rateToCdf: 3000,
    );
    final usdConfig = CurrencyConfigEntity(
      referenceCurrencyCode: 'USD',
      currencies: const [],
      snapshotsByKey: {
        usdSnapshot.cacheKey: usdSnapshot,
        eurSnapshot.cacheKey: eurSnapshot,
      },
    );

    final collection = builder.build(
      recurringTransferts: [
        plan(
          id: 'eur-monthly',
          frequency: Frequency.monthly,
          amount: 10,
          currency: 'EUR',
          startDate: rateDate,
          nextDueDate: rateDate,
        ),
        plan(
          id: 'usd-monthly',
          frequency: Frequency.monthly,
          amount: 20,
          currency: 'USD',
          startDate: rateDate,
          nextDueDate: rateDate,
        ),
      ],
      transactions: const [],
      currencyConfig: usdConfig,
      scope: RecurringPlanScope.charge,
      now: DateTime(2026, 4, 1),
    );

    expect(collection.monthlyReferenceAmount, closeTo(35, 0.0001));
  });

  test('monthly load converts mixed currencies when reference is CDF', () {
    final rateDate = DateTime(2026, 4, 1).toIso8601String();
    final usdSnapshot = ExchangeRateSnapshotEntity(
      currencyCode: 'USD',
      rateDate: rateDate,
      rateToCdf: 2,
    );
    final eurSnapshot = ExchangeRateSnapshotEntity(
      currencyCode: 'EUR',
      rateDate: rateDate,
      rateToCdf: 3,
    );
    final cdfConfig = CurrencyConfigEntity(
      referenceCurrencyCode: 'CDF',
      currencies: const [],
      snapshotsByKey: {
        usdSnapshot.cacheKey: usdSnapshot,
        eurSnapshot.cacheKey: eurSnapshot,
      },
    );

    final collection = builder.build(
      recurringTransferts: [
        plan(
          id: 'usd-a',
          frequency: Frequency.monthly,
          amount: 100,
          currency: 'USD',
          startDate: rateDate,
          nextDueDate: rateDate,
        ),
        plan(
          id: 'usd-b',
          frequency: Frequency.monthly,
          amount: 100,
          currency: 'USD',
          startDate: rateDate,
          nextDueDate: rateDate,
        ),
        plan(
          id: 'eur-a',
          frequency: Frequency.monthly,
          amount: 100,
          currency: 'EUR',
          startDate: rateDate,
          nextDueDate: rateDate,
        ),
      ],
      transactions: const [],
      currencyConfig: cdfConfig,
      scope: RecurringPlanScope.charge,
      now: DateTime(2026, 4, 1),
    );

    expect(collection.monthlyReferenceAmount, closeTo(700, 0.0001));
  });
}
