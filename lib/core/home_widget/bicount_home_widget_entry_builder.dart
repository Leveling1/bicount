import 'package:bicount/core/home_widget/bicount_home_widget_action.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_entry.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/transaction_direction_service.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/home/domain/services/home_monthly_flow_service.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Builds the single rich snapshot every home widget size reads from.
/// Every color is derived from [Theme.of(context)] so the widget always
/// mirrors the app's own light/dark palette instead of hardcoded values.
class BicountHomeWidgetEntryBuilder {
  const BicountHomeWidgetEntryBuilder({
    this.salaryDashboardBuilder = const SalaryDashboardBuilder(),
    this.recurringPlanCollectionBuilder =
        const RecurringPlanCollectionBuilder(),
    this.directionService = const TransactionDirectionService(),
    this.monthlyFlowService = const HomeMonthlyFlowService(),
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final SalaryDashboardBuilder salaryDashboardBuilder;
  final RecurringPlanCollectionBuilder recurringPlanCollectionBuilder;
  final TransactionDirectionService directionService;

  /// Same service the Home screen uses, so the widget never contradicts
  /// what the app shows: "In" carries over last month's leftover and every
  /// amount is converted to the reference currency before being summed.
  final HomeMonthlyFlowService monthlyFlowService;
  final CurrencyAmountService currencyAmountService;

  BicountHomeWidgetEntry build({
    required BuildContext context,
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final l10n = context.l10n;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final titleColor = _colorValue(
      Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textColorLight,
    );
    final subtitleColor = _colorValue(
      Theme.of(context).textTheme.bodySmall?.color ??
          Theme.of(context).textTheme.bodyMedium?.color ??
          AppColors.secondaryTextColorLight,
    );
    final buttonTextColor = _colorValue(
      isDarkTheme ? AppColors.surfaceColorLight : AppColors.backgroundColorLight,
    );
    final positiveColor = _colorValue(Theme.of(context).primaryColor);
    final negativeColor = _colorValue(Theme.of(context).colorScheme.error);

    final balance = data.user.balance ?? 0.0;
    final addTransactionUri = BicountHomeWidgetAction.addTransactionUri()
        .toString();
    final addIncomeUri = BicountHomeWidgetAction.addIncomeUri().toString();
    final addExpenseUri = BicountHomeWidgetAction.addExpenseUri().toString();

    final now = DateTime.now();
    final monthTransactions = _thisMonthTransactions(data, now);
    final monthlyFlow = monthlyFlowService.build(
      data: data,
      currencyConfig: currencyConfig,
      now: now,
    );
    final monthIncome = monthlyFlow.inflowWithCarryover;
    final monthExpense = monthlyFlow.currentMonthOutflow;
    final monthDelta = monthIncome - monthExpense;
    final monthDeltaLabel = monthTransactions.isEmpty
        ? null
        : '${monthDelta >= 0 ? '+' : '-'}'
              '${NumberFormatUtils.formatCurrency(monthDelta.abs(), currencyCode: data.referenceCurrencyCode)} '
              '${l10n.homeWidgetThisMonthSuffix}';

    final next = _resolveNextItem(
      context: context,
      data: data,
      currencyConfig: currencyConfig,
      positiveColor: positiveColor,
      negativeColor: negativeColor,
      addTransactionUri: addTransactionUri,
    );

    final week = _weekExpenses(data, now, currencyConfig);
    final recent = _mostRecentTransaction(
      data: data,
      positiveColor: positiveColor,
      negativeColor: negativeColor,
    );
    final monthFlow = _monthDailyFlow(
      monthTransactions,
      data,
      now,
      currencyConfig,
    );
    final recentItems = _recentTransactions(
      data: data,
      positiveColor: positiveColor,
      negativeColor: negativeColor,
    );

    // Signed in either way: with no activity every amount really is zero, so
    // the card shows zeros rather than the signed-out placeholder.
    final hasActivity =
        recentItems.isNotEmpty || monthIncome != 0 || monthExpense != 0;

    return BicountHomeWidgetEntry(
      state: hasActivity
          ? BicountHomeWidgetState.populated
          : BicountHomeWidgetState.empty,
      isDarkTheme: isDarkTheme,
      eyebrow: l10n.homeWidgetEyebrow,
      balance: NumberFormatUtils.formatCurrency(
        balance,
        currencyCode: data.referenceCurrencyCode,
      ),
      balanceColor: balance < 0 ? negativeColor : titleColor,
      // The card background always opens the app on Home. Individual rows
      // carry their own deep link, so tapping the card no longer drops the
      // user straight into the salary confirmation form.
      mainActionUri: BicountHomeWidgetAction.openHomeUri().toString(),
      monthDeltaLabel: monthDeltaLabel,
      monthDeltaColor: monthDelta >= 0 ? positiveColor : negativeColor,
      monthIncomeValue: monthIncome,
      monthIncomeLabel: NumberFormatUtils.formatCurrency(
        monthIncome,
        currencyCode: data.referenceCurrencyCode,
      ),
      monthIncomeColor: monthIncome < 0 ? negativeColor : positiveColor,
      monthExpenseValue: monthExpense,
      monthExpenseLabel: NumberFormatUtils.formatCurrency(
        monthExpense,
        currencyCode: data.referenceCurrencyCode,
      ),
      nextItemLabel: next?.label,
      nextItemAmountLabel: next?.amountLabel,
      nextItemAmountColor: next?.amountColor,
      nextItemActionUri: next?.actionUri,
      weekDayLabels: week.dayLabels,
      weekValues: week.values,
      weekHighlightIndex: week.values.isEmpty ? null : week.values.length - 1,
      recentItemLabel: recent?.label,
      recentItemAmountLabel: recent?.amountLabel,
      recentItemAmountColor: recent?.amountColor,
      monthDailyIncome: monthFlow.income,
      monthDailyExpense: monthFlow.expense,
      monthCurveLabel: l10n.homeWidgetMonthFlowLabel,
      incomeLegendLabel: l10n.homeWidgetEntriesLabel,
      expenseLegendLabel: l10n.homeWidgetExitsLabel,
      recentItems: recentItems,
      singleButtonLabel: l10n.homeWidgetAddCta,
      singleButtonActionUri: addTransactionUri,
      incomeButtonLabel: l10n.homeWidgetIncomeCta,
      incomeButtonActionUri: addIncomeUri,
      expenseButtonLabel: l10n.homeWidgetExpenseCta,
      expenseButtonActionUri: addExpenseUri,
      monthSectionLabel: l10n.homeWidgetThisMonthLabel,
      nextItemSectionLabel: l10n.homeWidgetNextSubscriptionLabel,
      weekSectionLabel: l10n.homeWidgetWeekExpensesLabel,
      weekSectionCompactLabel: l10n.homeWidgetWeekExpensesCompactLabel,
      entriesLabel: l10n.homeWidgetEntriesLabel,
      exitsLabel: l10n.homeWidgetExitsLabel,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      buttonTextColor: buttonTextColor,
    );
  }

  List<TransactionModel> _thisMonthTransactions(MainEntity data, DateTime now) {
    return data.transactions.where((transaction) {
      final date = DateTime.tryParse(transaction.date)?.toLocal();
      return date != null &&
          date.year == now.year &&
          date.month == now.month;
    }).toList(growable: false);
  }

  _NextItem? _resolveNextItem({
    required BuildContext context,
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
    required int positiveColor,
    required int negativeColor,
    required String addTransactionUri,
  }) {
    final confirmation = _resolveConfirmation(
      data: data,
      currencyConfig: currencyConfig,
    );
    if (confirmation != null) {
      return _NextItem(
        label:
            '${confirmation.source} — ${_relativeDay(context, confirmation.expectedDate)}',
        amountLabel: NumberFormatUtils.formatCurrency(
          confirmation.amount,
          currencyCode: confirmation.currency,
        ),
        amountColor: positiveColor,
        actionUri: BicountHomeWidgetAction.recurringConfirmationUri(
          recurringFundingId:
              confirmation.recurringTransfert.recurringTransfertId ?? '',
          expectedDate: _normalizeDateToken(confirmation.expectedDate),
        ).toString(),
      );
    }

    final upcoming = _resolveUpcoming(data: data, currencyConfig: currencyConfig);
    if (upcoming != null) {
      final recurringTypeId =
          upcoming.summary.recurringTransfert.recurringTransfertTypeId;
      final isExpense = TransactionTypes.isExpenseType(recurringTypeId);
      return _NextItem(
        label:
            '${upcoming.summary.recurringTransfert.title} — ${_relativeDay(context, upcoming.date)}',
        amountLabel:
            '${isExpense ? '-' : '+'}${NumberFormatUtils.formatCurrency(
          upcoming.summary.recurringTransfert.amount,
          currencyCode: upcoming.summary.recurringTransfert.currency,
        )}',
        amountColor: isExpense ? negativeColor : positiveColor,
        actionUri: _upcomingActionUri(upcoming.summary, upcoming.date).toString(),
      );
    }

    return null;
  }

  _WeekExpenses _weekExpenses(
    MainEntity data,
    DateTime now,
    CurrencyConfigEntity currencyConfig,
  ) {
    final today = _startOfDay(now);
    final start = today.subtract(const Duration(days: 6));
    final buckets = List<double>.filled(7, 0);

    for (final transaction in data.transactions) {
      final direction = directionService.resolveFromModel(
        transaction: transaction,
        currentUserId: data.user.uid,
        friends: data.friends,
      );
      if (direction.sign != TransactionSign.negative) {
        continue;
      }
      final date = DateTime.tryParse(transaction.date)?.toLocal();
      if (date == null) {
        continue;
      }
      final day = _startOfDay(date);
      final index = day.difference(start).inDays;
      if (index < 0 || index > 6) {
        continue;
      }
      buckets[index] += currencyAmountService.transaction(
        transaction,
        currencyConfig,
      );
    }

    final locale = _resolvedLocale();
    final dayLabels = List<String>.generate(7, (index) {
      final day = start.add(Duration(days: index));
      final label = DateFormat.E(locale).format(day);
      return label.isEmpty ? '' : label[0].toUpperCase();
    });

    return _WeekExpenses(values: buckets, dayLabels: dayLabels);
  }

  _RecentItem? _mostRecentTransaction({
    required MainEntity data,
    required int positiveColor,
    required int negativeColor,
  }) {
    TransactionModel? latest;
    DateTime? latestDate;
    for (final transaction in data.transactions) {
      final date = DateTime.tryParse(transaction.date)?.toLocal();
      if (date == null) {
        continue;
      }
      if (latestDate == null || date.isAfter(latestDate)) {
        latest = transaction;
        latestDate = date;
      }
    }
    if (latest == null) {
      return null;
    }

    final direction = directionService.resolveFromModel(
      transaction: latest,
      currentUserId: data.user.uid,
      friends: data.friends,
    );
    final isExpense = direction.sign == TransactionSign.negative;
    return _RecentItem(
      label: latest.name,
      amountLabel:
          '${isExpense ? '-' : '+'}${NumberFormatUtils.formatCurrency(latest.amount, currencyCode: latest.currency)}',
      amountColor: isExpense ? negativeColor : positiveColor,
    );
  }

  /// Per-day income and expense totals from the 1st of the month up to
  /// today, so the large layouts can draw two comparable curves.
  _MonthFlow _monthDailyFlow(
    List<TransactionModel> monthTransactions,
    MainEntity data,
    DateTime now,
    CurrencyConfigEntity currencyConfig,
  ) {
    final dayCount = now.day;
    final income = List<double>.filled(dayCount, 0);
    final expense = List<double>.filled(dayCount, 0);

    for (final transaction in monthTransactions) {
      final date = DateTime.tryParse(transaction.date)?.toLocal();
      if (date == null || date.day < 1 || date.day > dayCount) {
        continue;
      }
      final index = date.day - 1;
      final direction = directionService.resolveFromModel(
        transaction: transaction,
        currentUserId: data.user.uid,
        friends: data.friends,
      );
      // Converted, never raw: a day mixing 666 Fc and 10 $ would otherwise
      // add up to a meaningless number.
      final amount = currencyAmountService.transaction(
        transaction,
        currencyConfig,
      );
      if (direction.sign == TransactionSign.positive) {
        income[index] += amount;
      } else if (direction.sign == TransactionSign.negative) {
        expense[index] += amount;
      }
    }

    return _MonthFlow(income: income, expense: expense);
  }

  List<BicountHomeWidgetRecentItem> _recentTransactions({
    required MainEntity data,
    required int positiveColor,
    required int negativeColor,
    int limit = 12,
  }) {
    final dated = <MapEntry<DateTime, TransactionModel>>[];
    for (final transaction in data.transactions) {
      final date = DateTime.tryParse(transaction.date)?.toLocal();
      if (date == null) {
        continue;
      }
      dated.add(MapEntry(date, transaction));
    }
    dated.sort((left, right) => right.key.compareTo(left.key));

    return dated.take(limit).map((entry) {
      final transaction = entry.value;
      final direction = directionService.resolveFromModel(
        transaction: transaction,
        currentUserId: data.user.uid,
        friends: data.friends,
      );
      final isExpense = direction.sign == TransactionSign.negative;
      return BicountHomeWidgetRecentItem(
        label: transaction.name,
        amountLabel:
            '${isExpense ? '-' : '+'}${NumberFormatUtils.formatCurrency(transaction.amount, currencyCode: transaction.currency)}',
        amountColor: isExpense ? negativeColor : positiveColor,
        actionUri: BicountHomeWidgetAction.openTransactionUri(
          transaction.tid ?? '',
        ).toString(),
      );
    }).toList(growable: false);
  }

  SalaryOccurrenceEntity? _resolveConfirmation({
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final dashboard = salaryDashboardBuilder.build(
      recurringTransferts: data.recurringTransferts,
      transactions: data.transactions,
      currencyConfig: currencyConfig,
    );
    if (dashboard.attentionOccurrences.isEmpty) {
      return null;
    }
    return dashboard.attentionOccurrences.first;
  }

  _UpcomingRecurringCandidate? _resolveUpcoming({
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final today = _startOfDay(DateTime.now());
    final collections = [
      recurringPlanCollectionBuilder.build(
        recurringTransferts: data.recurringTransferts,
        transactions: data.transactions,
        currencyConfig: currencyConfig,
        scope: RecurringPlanScope.charge,
      ),
      recurringPlanCollectionBuilder.build(
        recurringTransferts: data.recurringTransferts,
        transactions: data.transactions,
        currencyConfig: currencyConfig,
        scope: RecurringPlanScope.income,
      ),
    ];
    final candidates = <_UpcomingRecurringCandidate>[];

    for (final collection in collections) {
      for (final summary in collection.plans) {
        final nextExpectedDate = summary.nextExpectedDate;
        if (!summary.isActive || nextExpectedDate == null) {
          continue;
        }
        final date = _startOfDay(nextExpectedDate);
        final difference = date.difference(today).inDays;
        if (difference < 0 || difference > 2) {
          continue;
        }
        candidates.add(
          _UpcomingRecurringCandidate(
            summary: summary,
            date: date,
            priority:
                TransactionTypes.isExpenseType(
                  summary.recurringTransfert.recurringTransfertTypeId,
                )
                ? 0
                : 1,
          ),
        );
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((left, right) {
      final byDate = left.date.compareTo(right.date);
      if (byDate != 0) {
        return byDate;
      }
      return left.priority.compareTo(right.priority);
    });
    return candidates.first;
  }

  Uri _upcomingActionUri(
    RecurringPlanSummaryEntity summary,
    DateTime nextExpectedDate,
  ) {
    final recurringTransfert = summary.recurringTransfert;
    return switch (recurringTransfert.recurringTransfertTypeId) {
      TransactionTypes.salaryCode =>
        BicountHomeWidgetAction.recurringConfirmationUri(
          recurringFundingId: recurringTransfert.recurringTransfertId ?? '',
          expectedDate: _normalizeDateToken(nextExpectedDate),
        ),
      TransactionTypes.otherRecurringIncomeCode =>
        BicountHomeWidgetAction.recurringIncomesUri(),
      _ => BicountHomeWidgetAction.recurringChargesUri(),
    };
  }

  String _relativeDay(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final today = _startOfDay(DateTime.now());
    final diff = _startOfDay(date).difference(today).inDays;
    if (diff <= 0) {
      return l10n.homeWidgetToday;
    }
    if (diff == 1) {
      return l10n.homeWidgetTomorrow;
    }
    return l10n.homeWidgetInDays(diff);
  }

  int _colorValue(Color color) => color.toARGB32();

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _normalizeDateToken(DateTime date) =>
      date.toIso8601String().split('T').first;

  String _resolvedLocale() {
    final locale = Intl.getCurrentLocale();
    if (locale.isEmpty || locale == 'und') {
      return 'en';
    }
    return locale;
  }
}

class _NextItem {
  const _NextItem({
    required this.label,
    required this.amountLabel,
    required this.amountColor,
    required this.actionUri,
  });

  final String label;
  final String amountLabel;
  final int amountColor;
  final String actionUri;
}

class _RecentItem {
  const _RecentItem({
    required this.label,
    required this.amountLabel,
    required this.amountColor,
  });

  final String label;
  final String amountLabel;
  final int amountColor;
}

class _WeekExpenses {
  const _WeekExpenses({required this.values, required this.dayLabels});

  final List<double> values;
  final List<String> dayLabels;
}

class _UpcomingRecurringCandidate {
  const _UpcomingRecurringCandidate({
    required this.summary,
    required this.date,
    required this.priority,
  });

  final RecurringPlanSummaryEntity summary;
  final DateTime date;
  final int priority;
}

class _MonthFlow {
  const _MonthFlow({required this.income, required this.expense});

  final List<double> income;
  final List<double> expense;
}
