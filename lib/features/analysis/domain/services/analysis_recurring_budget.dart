import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';

typedef RecurringBudgetCharge = ({
  String title,
  double originalAmount,
  String currency,
  double amount,
});

class AnalysisRecurringBudget {
  const AnalysisRecurringBudget._(this.income, this.charges);

  final double? income;
  final List<RecurringBudgetCharge> charges;

  double get totalCharges =>
      charges.fold(0, (total, charge) => total + charge.amount);

  static AnalysisRecurringBudget? fromAgenda(
    Iterable<AnalysisRecurringEntry> entries,
    CurrencyConfigEntity config,
  ) {
    final incomes = <RecurringTransfertModel, int>{};
    final expenses = <RecurringTransfertModel, int>{};
    for (final entry in entries) {
      final plans = entry.scope == RecurringPlanScope.income
          ? incomes
          : expenses;
      plans.update(entry.plan, (count) => count + 1, ifAbsent: () => 1);
    }
    if (incomes.isEmpty || expenses.isEmpty) return null;

    final reference = CurrencyConfigEntity.normalizeCode(
      config.referenceCurrencyCode,
    );
    final rates = <String, double?>{};
    double? convert(double amount, String currency) {
      if (!amount.isFinite) return null;
      final source = CurrencyConfigEntity.normalizeCode(currency);
      if (source == reference) return amount;
      final sourceRate = rates.putIfAbsent(
        source,
        () => config.latestRateToCdf(source),
      );
      final referenceRate = rates.putIfAbsent(
        reference,
        () => config.latestRateToCdf(reference),
      );
      if (sourceRate == null ||
          referenceRate == null ||
          !sourceRate.isFinite ||
          !referenceRate.isFinite ||
          sourceRate <= 0 ||
          referenceRate <= 0) {
        return null;
      }
      final converted = (amount * sourceRate) / referenceRate;
      return converted.isFinite ? converted : null;
    }

    var income = 0.0;
    for (final entry in incomes.entries) {
      final amount = convert(
        entry.key.amount * entry.value,
        entry.key.currency,
      );
      if (amount == null) return const AnalysisRecurringBudget._(null, []);
      income += amount;
    }
    final charges = <RecurringBudgetCharge>[];
    for (final entry in expenses.entries) {
      final plan = entry.key;
      final originalAmount = plan.amount * entry.value;
      final amount = convert(originalAmount, plan.currency);
      if (amount == null) return const AnalysisRecurringBudget._(null, []);
      charges.add((
        title: plan.title,
        originalAmount: originalAmount,
        currency: plan.currency,
        amount: amount,
      ));
    }
    charges.sort((a, b) {
      final byAmount = b.amount.compareTo(a.amount);
      return byAmount == 0 ? a.title.compareTo(b.title) : byAmount;
    });
    final budget = AnalysisRecurringBudget._(income, charges);
    return income.isFinite && budget.totalCharges.isFinite
        ? budget
        : const AnalysisRecurringBudget._(null, []);
  }
}
