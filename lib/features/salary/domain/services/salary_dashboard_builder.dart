import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/salary/domain/entities/salary_dashboard_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_plan_summary_entity.dart';

class SalaryDashboardBuilder {
  const SalaryDashboardBuilder({
    this.scheduleService = const RecurringFundingScheduleService(),
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final RecurringFundingScheduleService scheduleService;
  final CurrencyAmountService currencyAmountService;

  SalaryDashboardEntity build({
    required List<RecurringFundingModel> recurringFundings,
    required List<AccountFundingModel> accountFundings,
    required CurrencyConfigEntity currencyConfig,
    DateTime? now,
  }) {
    final today = scheduleService.startOfDay(now ?? DateTime.now());
    final fundingsByOccurrenceKey = <String, AccountFundingModel>{};
    for (final funding in accountFundings) {
      final fundingDate = scheduleService.parseDate(funding.date);
      if (fundingDate == null) {
        continue;
      }
      final key = scheduleService.occurrenceMatchKey(
        ownerUid: funding.sid,
        source: funding.source,
        fundingType: funding.fundingType,
        amount: funding.amount,
        currency: funding.currency,
        expectedDate: fundingDate,
      );
      fundingsByOccurrenceKey.putIfAbsent(key, () => funding);
    }

    final plans = <SalaryPlanSummaryEntity>[];
    final attention = <SalaryOccurrenceEntity>[];
    final received = <SalaryOccurrenceEntity>[];
    double dueTodayAmount = 0;
    double overdueAmount = 0;
    int dueTodayCount = 0;
    int overdueCount = 0;

    final recurringPlans =
        recurringFundings
            .where((item) => RecurringFundingStatus.isActive(item.status))
            .toList()
          ..sort((left, right) => left.source.compareTo(right.source));

    for (final plan in recurringPlans) {
      final occurrences = _buildPlanOccurrences(
        recurringFunding: plan,
        fundingsByOccurrenceKey: fundingsByOccurrenceKey,
        currencyConfig: currencyConfig,
        today: today,
      );
      final requiresConfirmation = SalaryProcessingMode.requiresConfirmation(
        plan.salaryProcessingMode,
      );

      final overdueForPlan = occurrences
          .where(
            (item) =>
                requiresConfirmation &&
                item.state == AppSalaryOccurrenceState.overdue,
          )
          .toList(growable: false);
      final dueTodayForPlan = occurrences
          .where(
            (item) =>
                requiresConfirmation &&
                item.state == AppSalaryOccurrenceState.dueToday,
          )
          .toList(growable: false);

      attention.addAll(overdueForPlan);
      attention.addAll(dueTodayForPlan);
      received.addAll(
        occurrences.where((item) => item.isReceived).toList(growable: false),
      );

      overdueCount += overdueForPlan.length;
      dueTodayCount += dueTodayForPlan.length;
      overdueAmount += overdueForPlan.fold<double>(
        0,
        (sum, item) => sum + item.referenceAmount,
      );
      dueTodayAmount += dueTodayForPlan.fold<double>(
        0,
        (sum, item) => sum + item.referenceAmount,
      );

      plans.add(
        SalaryPlanSummaryEntity(
          recurringFunding: plan,
          nextExpectedDate: _resolveNextExpectedDate(
            occurrences: occurrences,
            today: today,
          ),
          overdueCount: overdueForPlan.length,
          dueTodayCount: dueTodayForPlan.length,
          outstandingReferenceAmount:
              overdueForPlan.fold<double>(
                0,
                (sum, item) => sum + item.referenceAmount,
              ) +
              dueTodayForPlan.fold<double>(
                0,
                (sum, item) => sum + item.referenceAmount,
              ),
        ),
      );
    }

    attention.sort(
      (left, right) => left.expectedDate.compareTo(right.expectedDate),
    );
    received.sort((left, right) {
      final leftDate = left.receivedDate ?? left.expectedDate;
      final rightDate = right.receivedDate ?? right.expectedDate;
      return rightDate.compareTo(leftDate);
    });

    final nextExpectedDate = plans
        .map((item) => item.nextExpectedDate)
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (current, value) =>
              current == null || value.isBefore(current) ? value : current,
        );

    return SalaryDashboardEntity(
      plans: plans,
      attentionOccurrences: attention,
      recentReceivedOccurrences: received.take(6).toList(growable: false),
      dueTodayAmount: dueTodayAmount,
      overdueAmount: overdueAmount,
      dueTodayCount: dueTodayCount,
      overdueCount: overdueCount,
      nextExpectedDate: nextExpectedDate,
    );
  }

  List<SalaryOccurrenceEntity> _buildPlanOccurrences({
    required RecurringFundingModel recurringFunding,
    required Map<String, AccountFundingModel> fundingsByOccurrenceKey,
    required CurrencyConfigEntity currencyConfig,
    required DateTime today,
  }) {
    final startDate = scheduleService.parseDate(recurringFunding.startDate);
    if (startDate == null) {
      return const [];
    }

    final occurrences = <SalaryOccurrenceEntity>[];
    var cursor = scheduleService.startOfDay(startDate);

    while (!cursor.isAfter(today)) {
      occurrences.add(
        _buildOccurrence(
          recurringFunding: recurringFunding,
          expectedDate: cursor,
          fundingsByOccurrenceKey: fundingsByOccurrenceKey,
          currencyConfig: currencyConfig,
          today: today,
        ),
      );
      cursor = scheduleService.nextOccurrence(
        cursor,
        recurringFunding.frequency,
      );
    }

    if (recurringFunding.status == RecurringFundingStatus.active) {
      occurrences.add(
        _buildOccurrence(
          recurringFunding: recurringFunding,
          expectedDate: cursor,
          fundingsByOccurrenceKey: fundingsByOccurrenceKey,
          currencyConfig: currencyConfig,
          today: today,
        ),
      );
    }

    return occurrences;
  }

  SalaryOccurrenceEntity _buildOccurrence({
    required RecurringFundingModel recurringFunding,
    required DateTime expectedDate,
    required Map<String, AccountFundingModel> fundingsByOccurrenceKey,
    required CurrencyConfigEntity currencyConfig,
    required DateTime today,
  }) {
    final occurrenceId = scheduleService.occurrenceFundingId(
      recurringFunding.recurringFundingId,
      expectedDate,
    );
    final occurrenceKey = scheduleService.occurrenceMatchKey(
      ownerUid: recurringFunding.uid,
      source: recurringFunding.source,
      fundingType: recurringFunding.fundingType,
      amount: recurringFunding.amount,
      currency: recurringFunding.currency,
      expectedDate: expectedDate,
    );
    final receivedFunding = fundingsByOccurrenceKey[occurrenceKey];
    final referenceAmount = receivedFunding == null
        ? currencyAmountService.record(
            originalAmount: recurringFunding.amount,
            originalCurrencyCode: recurringFunding.currency,
            fxRateDate: expectedDate.toIso8601String(),
            config: currencyConfig,
          )
        : currencyAmountService.funding(receivedFunding, currencyConfig);

    return SalaryOccurrenceEntity(
      occurrenceId: occurrenceId,
      recurringFunding: recurringFunding,
      receivedFunding: receivedFunding,
      expectedDate: expectedDate,
      state: _resolveOccurrenceState(
        expectedDate: expectedDate,
        today: today,
        receivedFunding: receivedFunding,
      ),
      referenceAmount: referenceAmount,
    );
  }

  DateTime? _resolveNextExpectedDate({
    required List<SalaryOccurrenceEntity> occurrences,
    required DateTime today,
  }) {
    for (final occurrence in occurrences) {
      if (!occurrence.expectedDate.isBefore(today)) {
        return occurrence.expectedDate;
      }
    }
    return occurrences.isEmpty ? null : occurrences.last.expectedDate;
  }

  int _resolveOccurrenceState({
    required DateTime expectedDate,
    required DateTime today,
    required AccountFundingModel? receivedFunding,
  }) {
    if (receivedFunding != null) {
      return AppSalaryOccurrenceState.received;
    }

    final normalizedExpected = scheduleService.startOfDay(expectedDate);
    if (normalizedExpected.isAtSameMomentAs(today)) {
      return AppSalaryOccurrenceState.dueToday;
    }
    if (normalizedExpected.isBefore(today)) {
      return AppSalaryOccurrenceState.overdue;
    }
    return AppSalaryOccurrenceState.upcoming;
  }
}
