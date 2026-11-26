import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_schedule.dart';
import 'package:bicount/features/salary/domain/entities/salary_dashboard_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_plan_summary_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:intl/intl.dart';

class SalaryDashboardBuilder {
  const SalaryDashboardBuilder({
    this.scheduleService = const RecurringFundingScheduleService(),
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final RecurringFundingScheduleService scheduleService;
  final CurrencyAmountService currencyAmountService;

  SalaryDashboardEntity build({
    required List<RecurringTransfertModel> recurringTransferts,
    required List<TransactionModel> transactions,
    required CurrencyConfigEntity currencyConfig,
    DateTime? now,
  }) {
    final today = scheduleService.startOfDay(now ?? DateTime.now());
    final transactionsByOccurrenceKey = <String, TransactionModel>{};
    final receivedDatesByPlan = <String, Set<DateTime>>{};
    for (final transaction in transactions) {
      final originId = transaction.originId ?? transaction.recurringTransfertId;
      if (originId == null || originId.isEmpty) {
        continue;
      }
      final occurrenceDate =
          scheduleService.parseDate(transaction.originOccurrenceDate) ??
          scheduleService.parseDate(transaction.recurringOccurrenceDate) ??
          scheduleService.parseDate(transaction.date);
      if (occurrenceDate == null) {
        continue;
      }
      final key = _occurrenceKey(originId, occurrenceDate);
      transactionsByOccurrenceKey.putIfAbsent(key, () => transaction);
      receivedDatesByPlan
          .putIfAbsent(originId, () => {})
          .add(scheduleService.startOfDay(occurrenceDate));
    }

    final plans = <SalaryPlanSummaryEntity>[];
    final attention = <SalaryOccurrenceEntity>[];
    final received = <SalaryOccurrenceEntity>[];
    double dueTodayAmount = 0;
    double overdueAmount = 0;
    int dueTodayCount = 0;
    int overdueCount = 0;

    final salaryPlans =
        recurringTransferts
            .where(
              (item) =>
                  item.recurringTransfertTypeId ==
                      TransactionTypes.salaryCode &&
                  item.hasSchedule,
            )
            .toList()
          ..sort((left, right) => left.title.compareTo(right.title));

    for (final plan in salaryPlans) {
      final occurrences = _buildPlanOccurrences(
        recurringTransfert: plan,
        transactionsByOccurrenceKey: transactionsByOccurrenceKey,
        currencyConfig: currencyConfig,
        today: today,
        receivedDates:
            receivedDatesByPlan[plan.recurringTransfertId] ?? const {},
      );
      final requiresConfirmation =
          !plan.isPaused &&
          AppExecutionMode.requiresConfirmation(plan.executionMode);

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
          recurringTransfert: plan,
          nextExpectedDate: plan.isPaused
              ? null
              : _resolveNextExpectedDate(
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
    required RecurringTransfertModel recurringTransfert,
    required Map<String, TransactionModel> transactionsByOccurrenceKey,
    required CurrencyConfigEntity currencyConfig,
    required DateTime today,
    required Set<DateTime> receivedDates,
  }) {
    final startDate = scheduleService.parseDate(recurringTransfert.startDate);
    if (startDate == null) {
      return const [];
    }
    final schedule = RecurringPlanSchedule(scheduleService: scheduleService);
    final dates = {...receivedDates};
    for (final date in schedule.occurrences(
      recurringTransfert,
      from: startDate,
    )) {
      dates.add(date);
      if (date.isAfter(today)) break;
    }
    return [
      for (final date in dates.toList()..sort())
        _buildOccurrence(
          recurringTransfert: recurringTransfert,
          expectedDate: date,
          transactionsByOccurrenceKey: transactionsByOccurrenceKey,
          currencyConfig: currencyConfig,
          today: today,
        ),
    ];
  }

  SalaryOccurrenceEntity _buildOccurrence({
    required RecurringTransfertModel recurringTransfert,
    required DateTime expectedDate,
    required Map<String, TransactionModel> transactionsByOccurrenceKey,
    required CurrencyConfigEntity currencyConfig,
    required DateTime today,
  }) {
    final occurrenceId = _occurrenceKey(
      recurringTransfert.recurringTransfertId ?? '',
      expectedDate,
    );
    final receivedTransaction = transactionsByOccurrenceKey[occurrenceId];
    final referenceAmount = receivedTransaction == null
        ? currencyAmountService.record(
            originalAmount: recurringTransfert.amount,
            originalCurrencyCode: recurringTransfert.currency,
            fxRateDate: _fxAnchorDate(recurringTransfert),
            config: currencyConfig,
          )
        : currencyAmountService.transaction(
            receivedTransaction,
            currencyConfig,
          );

    return SalaryOccurrenceEntity(
      occurrenceId: occurrenceId,
      recurringTransfert: recurringTransfert,
      receivedTransaction: receivedTransaction,
      expectedDate: expectedDate,
      state: _resolveOccurrenceState(
        expectedDate: expectedDate,
        today: today,
        receivedTransaction: receivedTransaction,
      ),
      referenceAmount: referenceAmount,
    );
  }

  String _fxAnchorDate(RecurringTransfertModel recurringTransfert) {
    final createdAt = recurringTransfert.createdAt;
    if (createdAt != null && createdAt.isNotEmpty) {
      return createdAt;
    }

    return scheduleService.normalizeDate(recurringTransfert.startDate);
  }

  DateTime? _resolveNextExpectedDate({
    required List<SalaryOccurrenceEntity> occurrences,
    required DateTime today,
  }) {
    for (final occurrence in occurrences) {
      if (!occurrence.isReceived && !occurrence.expectedDate.isBefore(today)) {
        return occurrence.expectedDate;
      }
    }
    return occurrences.isEmpty ? null : occurrences.last.expectedDate;
  }

  int _resolveOccurrenceState({
    required DateTime expectedDate,
    required DateTime today,
    required TransactionModel? receivedTransaction,
  }) {
    if (receivedTransaction != null) {
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

  String _occurrenceKey(String recurringTransfertId, DateTime value) {
    return '$recurringTransfertId-${DateFormat('yyyyMMdd').format(value)}';
  }
}
