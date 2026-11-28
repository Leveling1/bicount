import 'package:bicount/core/animations/bicount_pressable.dart';
import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/widgets/app_popup_menu_item.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_budget.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_budget_card.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'analysis_recurring_budget_period_menu.dart';

class AnalysisRecurringBudgetSection extends StatefulWidget {
  const AnalysisRecurringBudgetSection({super.key});

  @override
  State<AnalysisRecurringBudgetSection> createState() =>
      _AnalysisRecurringBudgetSectionState();
}

class _AnalysisRecurringBudgetSectionState
    extends State<AnalysisRecurringBudgetSection> {
  final _today = DateTime.now();
  late var _month = DateTime(_today.year, _today.month);

  @override
  Widget build(BuildContext context) {
    final data = context.select(
      (MainBloc bloc) => switch (bloc.state) {
        MainLoaded(:final startData) => startData,
        _ => null,
      },
    );
    if (data == null) return const SizedBox.shrink();
    final plans = data.recurringTransferts;
    final hasBothScopes = RecurringPlanScope.values.every(
      (scope) =>
          plans.any((plan) => scope.matchesType(plan.recurringTransfertTypeId)),
    );
    if (!hasBothScopes) return const SizedBox.shrink();

    final config = context.select((CurrencyCubit cubit) => cubit.state.config);
    final budget = AnalysisRecurringBudget.forRange(
      start: _month,
      end: DateTime(_month.year, _month.month + 1, 0),
      plans: plans,
      transactions: data.transactions,
      config: config,
    );
    final l10n = context.l10n;
    final monthFormat = DateFormat.MMMM(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final material = MaterialLocalizations.of(context);
    final (firstYear, lastYear) = _yearBounds(plans);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        0,
        AppDimens.paddingMedium,
        AppDimens.marginLarge,
      ),
      child: DetailsCard(
        isMargin: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppDimens.spacingMedium,
          children: [
            Text(
              l10n.analysisRecurringBudget,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final monthControl = _BudgetPeriodMenu(
                  key: const ValueKey('recurring_budget_month'),
                  title: l10n.analysisRecurringBudgetMonth,
                  value: _month.month,
                  options: {
                    for (var month = 1; month <= 12; month++)
                      month: monthFormat.format(DateTime(2000, month)),
                  },
                  onChanged: (month) {
                    setState(() => _month = DateTime(_month.year, month));
                  },
                );
                final yearControl = _BudgetPeriodMenu(
                  key: const ValueKey('recurring_budget_year'),
                  title: l10n.analysisRecurringBudgetYear,
                  value: _month.year,
                  options: {
                    for (var year = lastYear; year >= firstYear; year--)
                      year: material.formatYear(DateTime(year)),
                  },
                  onChanged: (year) {
                    setState(() => _month = DateTime(year, _month.month));
                  },
                );
                final textScale =
                    MediaQuery.textScalerOf(context).scale(16) / 16;
                if (constraints.maxWidth < AppSizes.dp280 * textScale) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppDimens.spacingSmall,
                    children: [monthControl, yearControl],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppDimens.spacingSmall,
                  children: [
                    Expanded(flex: 3, child: monthControl),
                    Expanded(flex: 2, child: yearControl),
                  ],
                );
              },
            ),
            if (budget == null)
              Text(
                l10n.analysisRecurringBudgetEmptyMonth,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              AnalysisRecurringBudgetCard(
                budget: budget,
                currency: config.referenceCurrencyCode,
                precision: config
                    .currencyFor(config.referenceCurrencyCode)
                    .decimals,
              ),
          ],
        ),
      ),
    );
  }

  (int, int) _yearBounds(List<RecurringTransfertModel> plans) {
    var first = math.min(_today.year, _month.year);
    var last = math.max(_today.year + 1, _month.year);
    const schedule = RecurringFundingScheduleService();
    for (final plan in plans) {
      final start = schedule.parseDate(plan.startDate);
      if (start != null) {
        first = math.min(first, start.year);
        last = math.max(last, start.year);
      }
      final nextDue = schedule.parseDate(plan.nextDueDate);
      if (nextDue != null) last = math.max(last, nextDue.year);
    }
    return (first, last);
  }
}
