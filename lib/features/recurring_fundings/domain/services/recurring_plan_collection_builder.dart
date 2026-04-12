import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_collection_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class RecurringPlanCollectionBuilder {
  const RecurringPlanCollectionBuilder({
    this.scheduleService = const RecurringFundingScheduleService(),
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final RecurringFundingScheduleService scheduleService;
  final CurrencyAmountService currencyAmountService;

  RecurringPlanCollectionEntity build({
    required List<RecurringTransfertModel> recurringTransferts,
    required List<TransactionModel> transactions,
    required CurrencyConfigEntity currencyConfig,
    required RecurringPlanScope scope,
    DateTime? now,
  }) {
    final today = scheduleService.startOfDay(now ?? DateTime.now());
    final plans =
        recurringTransferts
            .where((plan) => scope.matchesType(plan.recurringTransfertTypeId))
            .map(
              (plan) => _buildSummary(
                plan: plan,
                transactions: transactions,
                currencyConfig: currencyConfig,
                today: today,
              ),
            )
            .toList()
          ..sort(_compareSummaries);

    final activePlans = plans.where((plan) => plan.isActive).toList();
    final nextExpectedDate = activePlans
        .map((plan) => plan.nextExpectedDate)
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (current, value) =>
              current == null || value.isBefore(current) ? value : current,
        );

    return RecurringPlanCollectionEntity(
      plans: plans,
      activeCount: activePlans.length,
      upcomingCount: activePlans.where((plan) {
        final nextDate = plan.nextExpectedDate;
        if (nextDate == null) {
          return false;
        }
        final difference = nextDate.difference(today).inDays;
        return difference >= 0 && difference <= 7;
      }).length,
      monthlyReferenceAmount: activePlans.fold<double>(
        0,
        (sum, plan) => sum + plan.monthlyReferenceAmount,
      ),
      nextExpectedDate: nextExpectedDate,
    );
  }

  RecurringPlanSummaryEntity _buildSummary({
    required RecurringTransfertModel plan,
    required List<TransactionModel> transactions,
    required CurrencyConfigEntity currencyConfig,
    required DateTime today,
  }) {
    final linkedTransactions =
        transactions
            .where(
              (item) => item.recurringTransfertId == plan.recurringTransfertId,
            )
            .toList(growable: false)
          ..sort((left, right) => right.date.compareTo(left.date));

    return RecurringPlanSummaryEntity(
      recurringTransfert: plan,
      nextExpectedDate: _resolveNextExpectedDate(plan, today),
      lastRecordedDate: linkedTransactions.isEmpty
          ? null
          : scheduleService.parseDate(linkedTransactions.first.date),
      monthlyReferenceAmount: _monthlyReferenceAmount(plan, currencyConfig),
      totalRecordedReferenceAmount: linkedTransactions.fold<double>(
        0,
        (sum, item) =>
            sum + currencyAmountService.transaction(item, currencyConfig),
      ),
      recordedCount: linkedTransactions.length,
    );
  }

  DateTime? _resolveNextExpectedDate(
    RecurringTransfertModel plan,
    DateTime today,
  ) {
    if (!AppRecurringTransfertState.isActive(plan.status)) {
      return null;
    }

    final startDate = scheduleService.parseDate(plan.startDate);
    if (startDate == null) {
      return null;
    }
    final endDate = scheduleService.parseDate(plan.endDate);
    final frequency = _effectiveFrequency(plan.frequency);
    var cursor = scheduleService.startOfDay(startDate);

    while (cursor.isBefore(today)) {
      cursor = scheduleService.nextOccurrence(cursor, frequency);
    }

    if (endDate != null &&
        cursor.isAfter(scheduleService.startOfDay(endDate))) {
      return null;
    }

    return cursor;
  }

  double _monthlyReferenceAmount(
    RecurringTransfertModel plan,
    CurrencyConfigEntity currencyConfig,
  ) {
    final frequency = _effectiveFrequency(plan.frequency);
    final referenceAmount = currencyAmountService.record(
      originalAmount: plan.amount,
      originalCurrencyCode: plan.currency,
      fxRateDate: _fxAnchorDate(plan),
      config: currencyConfig,
    );

    return switch (frequency) {
      Frequency.weekly => referenceAmount * 52 / 12,
      Frequency.monthly => referenceAmount,
      Frequency.quarterly => referenceAmount / 3,
      Frequency.yearly => referenceAmount / 12,
      _ => referenceAmount,
    };
  }

  int _effectiveFrequency(int frequency) {
    return switch (frequency) {
      4 => Frequency.quarterly,
      5 => Frequency.yearly,
      _ => frequency,
    };
  }

  String _fxAnchorDate(RecurringTransfertModel plan) {
    final createdAt = plan.createdAt;
    if (createdAt != null && createdAt.isNotEmpty) {
      return createdAt;
    }

    return scheduleService.normalizeDate(plan.startDate);
  }

  int _compareSummaries(
    RecurringPlanSummaryEntity left,
    RecurringPlanSummaryEntity right,
  ) {
    if (left.isActive != right.isActive) {
      return left.isActive ? -1 : 1;
    }

    final leftDate = left.nextExpectedDate ?? DateTime(9999);
    final rightDate = right.nextExpectedDate ?? DateTime(9999);
    final byDate = leftDate.compareTo(rightDate);
    if (byDate != 0) {
      return byDate;
    }

    return left.recurringTransfert.title.compareTo(
      right.recurringTransfert.title,
    );
  }
}
