import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_action.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_entry.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:flutter/material.dart';

class BicountHomeWidgetEntryBuilder {
  const BicountHomeWidgetEntryBuilder({
    this.salaryDashboardBuilder = const SalaryDashboardBuilder(),
    this.recurringPlanCollectionBuilder =
        const RecurringPlanCollectionBuilder(),
  });

  final SalaryDashboardBuilder salaryDashboardBuilder;
  final RecurringPlanCollectionBuilder recurringPlanCollectionBuilder;

  BicountHomeWidgetEntry build({
    required BuildContext context,
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final titleColor = _colorValue(
      Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textColorLight,
    );
    final subtitleColor = _colorValue(
      Theme.of(context).textTheme.bodySmall?.color ??
          Theme.of(context).textTheme.bodyMedium?.color ??
          AppColors.secondaryTextColorLight,
    );
    final buttonTextColor = _colorValue(
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceColorLight
          : AppColors.backgroundColorLight,
    );
    final addTransactionUri = BicountHomeWidgetAction.addTransactionUri()
        .toString();
    final confirmation = _resolveConfirmation(
      data: data,
      currencyConfig: currencyConfig,
    );

    if (confirmation != null) {
      return BicountHomeWidgetEntry(
        isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        badge: context.l10n.salaryAttentionSectionTitle,
        title: confirmation.source,
        amount: NumberFormatUtils.formatCurrency(
          confirmation.amount,
          currencyCode: confirmation.currency,
        ),
        subtitle: context.l10n.homeWidgetDueOn(
          formatDate(confirmation.expectedDate),
        ),
        buttonLabel: context.l10n.homeWidgetAddTransactionCta,
        mainActionUri: BicountHomeWidgetAction.recurringConfirmationUri(
          recurringFundingId:
              confirmation.recurringTransfert.recurringTransfertId ?? '',
          expectedDate: _normalizeDateToken(confirmation.expectedDate),
        ).toString(),
        buttonActionUri: addTransactionUri,
        titleColor: titleColor,
        amountColor: _colorValue(Theme.of(context).primaryColor),
        subtitleColor: subtitleColor,
        buttonTextColor: buttonTextColor,
      );
    }

    final upcoming = _resolveUpcoming(
      data: data,
      currencyConfig: currencyConfig,
    );
    if (upcoming != null) {
      final recurringTypeId =
          upcoming.summary.recurringTransfert.recurringTransfertTypeId;
      return BicountHomeWidgetEntry(
        isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        badge: context.salaryOccurrenceStateLabel(
          AppSalaryOccurrenceState.upcoming,
        ),
        title: upcoming.summary.recurringTransfert.title,
        amount: NumberFormatUtils.formatCurrency(
          upcoming.summary.recurringTransfert.amount,
          currencyCode: upcoming.summary.recurringTransfert.currency,
        ),
        subtitle:
            '${TransactionTypes.typeLabel(context, recurringTypeId)} - '
            '${context.l10n.homeWidgetDueOn(formatDate(upcoming.date))}',
        buttonLabel: context.l10n.homeWidgetAddTransactionCta,
        mainActionUri: _upcomingActionUri(
          upcoming.summary,
          upcoming.date,
        ).toString(),
        buttonActionUri: addTransactionUri,
        titleColor: titleColor,
        amountColor: _colorValue(
          TransactionTypes.isExpenseType(recurringTypeId)
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).primaryColor,
        ),
        subtitleColor: subtitleColor,
        buttonTextColor: buttonTextColor,
      );
    }

    final balance = data.user.balance ?? 0.0;
    return BicountHomeWidgetEntry(
      isDarkTheme: Theme.of(context).brightness == Brightness.dark,
      badge: '',
      title: context.l10n.homeBalance,
      amount: NumberFormatUtils.formatCurrency(
        balance,
        currencyCode: data.referenceCurrencyCode,
      ),
      subtitle: context.l10n.homeWidgetBalanceFallbackSubtitle,
      buttonLabel: context.l10n.homeWidgetAddTransactionCta,
      mainActionUri: BicountHomeWidgetAction.openHomeUri().toString(),
      buttonActionUri: addTransactionUri,
      titleColor: titleColor,
      amountColor: _colorValue(
        balance < 0
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.textColorLight,
      ),
      subtitleColor: subtitleColor,
      buttonTextColor: buttonTextColor,
    );
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

  int _colorValue(Color color) => color.toARGB32();

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _normalizeDateToken(DateTime date) =>
      date.toIso8601String().split('T').first;
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
