import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

typedef RecurringBudgetCharge = ({
  String title,
  double originalAmount,
  String currency,
  double amount,
});

typedef _IncomeOccurrence = (String, DateTime);

class AnalysisRecurringBudget extends Equatable {
  const AnalysisRecurringBudget._(
    this.income,
    this.charges, {
    this.receivedIncome,
    this.plannedIncome,
  });

  final double? income;
  final List<RecurringBudgetCharge> charges;
  final double? receivedIncome;
  final double? plannedIncome;

  double get totalCharges =>
      charges.fold(0, (total, charge) => total + charge.amount);

  @override
  List<Object?> get props => [income, charges, receivedIncome, plannedIncome];

  static AnalysisRecurringBudget? forRange({
    required DateTime start,
    required DateTime end,
    required List<RecurringTransfertModel> plans,
    required List<TransactionModel> transactions,
    required CurrencyConfigEntity config,
  }) {
    const dates = RecurringFundingScheduleService();
    final agenda = const AnalysisRecurringAgenda().forRange(start, end, plans);
    final expenses = <RecurringTransfertModel, int>{};
    final scheduled = <_IncomeOccurrence, RecurringTransfertModel>{};
    final incomeIds = {
      for (final plan in plans)
        if (RecurringPlanScope.income.matchesType(
          plan.recurringTransfertTypeId,
        ))
          plan.recurringTransfertId,
    };

    for (final day in agenda.entries) {
      for (final entry in day.value) {
        final plan = entry.plan;
        if (entry.scope == RecurringPlanScope.charge) {
          expenses.update(plan, (count) => count + 1, ifAbsent: () => 1);
        } else if (plan.recurringTransfertId case final id?) {
          scheduled[(id, day.key)] = plan;
        }
      }
    }
    if (expenses.isEmpty) return null;

    final received = <_IncomeOccurrence, TransactionModel>{};
    for (final tx in transactions) {
      if (!RecurringPlanScope.income.matchesType(tx.type)) continue;
      final id = tx.recurringTransfertId ?? tx.originId;
      if (id == null || !incomeIds.contains(id)) continue;
      final date =
          dates.parseDate(tx.originOccurrenceDate) ??
          dates.parseDate(tx.recurringOccurrenceDate) ??
          dates.parseDate(tx.date);
      if (date == null) continue;
      final day = dates.startOfDay(date);
      if (day.isBefore(start) || day.isAfter(end)) continue;
      received.putIfAbsent((id, day), () => tx);
    }
    scheduled.removeWhere((key, _) => received.containsKey(key));
    if (scheduled.isEmpty && received.isEmpty) return null;

    final converter = _BudgetCurrencyConverter(config);
    var receivedTotal = 0.0;
    for (final booking in received.values) {
      final amount = converter.convert(
        booking.amount,
        booking.currency,
        tx: booking,
      );
      if (amount == null) return const AnalysisRecurringBudget._(null, []);
      receivedTotal += amount;
    }
    var plannedTotal = 0.0;
    for (final plan in scheduled.values) {
      final amount = converter.convert(plan.amount, plan.currency);
      if (amount == null) return const AnalysisRecurringBudget._(null, []);
      plannedTotal += amount;
    }
    final charges = <RecurringBudgetCharge>[];
    for (final entry in expenses.entries) {
      final plan = entry.key;
      final originalAmount = plan.amount * entry.value;
      final amount = converter.convert(originalAmount, plan.currency);
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
    final income = receivedTotal + plannedTotal;
    final budget = AnalysisRecurringBudget._(
      income,
      charges,
      receivedIncome: received.isEmpty ? null : receivedTotal,
      plannedIncome: scheduled.isEmpty ? null : plannedTotal,
    );
    return income.isFinite && budget.totalCharges.isFinite
        ? budget
        : const AnalysisRecurringBudget._(null, []);
  }
}

class _BudgetCurrencyConverter {
  _BudgetCurrencyConverter(this.config)
    : reference = CurrencyConfigEntity.normalizeCode(
        config.referenceCurrencyCode,
      );

  final CurrencyConfigEntity config;
  final String reference;
  final _latestRates = <String, double?>{};

  double? convert(double amount, String currency, {TransactionModel? tx}) {
    if (!amount.isFinite) return null;
    final source = CurrencyConfigEntity.normalizeCode(currency);
    if (source == reference) return amount;
    final converted = tx?.convertedAmount;
    if (tx?.referenceCurrencyCode == reference &&
        converted != null &&
        converted.isFinite) {
      return converted;
    }

    final storedRate = tx?.rateToCdf;
    final sourceRate =
        storedRate != null && storedRate.isFinite && storedRate > 0
        ? storedRate
        : _rate(source, tx?.fxRateDate);
    final cdf =
        tx?.amountCdf ?? (sourceRate == null ? null : amount * sourceRate);
    final referenceRate = _rate(reference, tx?.fxRateDate);
    if (cdf == null || referenceRate == null) return null;
    final result = cdf / referenceRate;
    return result.isFinite ? result : null;
  }

  double? _rate(String currency, String? day) {
    final snapshot = day == null
        ? null
        : config.snapshotFor(currencyCode: currency, rateDate: day);
    final rate =
        snapshot?.rateToCdf ??
        _latestRates.putIfAbsent(
          currency,
          () => config.latestRateToCdf(currency),
        );
    return rate != null && rate.isFinite && rate > 0 ? rate : null;
  }
}
