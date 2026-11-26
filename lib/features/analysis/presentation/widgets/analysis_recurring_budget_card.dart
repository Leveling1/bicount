import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_budget.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analysis_recurring_budget_waterfall.dart';

class AnalysisRecurringBudgetCard extends StatelessWidget {
  const AnalysisRecurringBudgetCard({
    super.key,
    required this.month,
    required this.agenda,
  });

  final DateTime month;
  final Map<DateTime, List<AnalysisRecurringEntry>> agenda;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<CurrencyCubit>().state.config;
    final budget = AnalysisRecurringBudget.fromAgenda(
      agenda.values.expand((day) => day),
      config,
    );
    if (budget == null) return const SizedBox.shrink();

    final title = context.l10n.analysisRecurringBudget;
    final monthLabel = MaterialLocalizations.of(context).formatMonthYear(month);
    final income = budget.income;
    final currency = config.referenceCurrencyCode;
    final difference = (income ?? 0) - budget.totalCharges;
    final precision = config.currencyFor(currency).decimals.clamp(0, 4);
    final roundTo = math.pow(10, precision);
    final remaining = (difference * roundTo).abs() < 0.5 ? 0.0 : difference;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        0,
        AppDimens.paddingMedium,
        0,
      ),
      child: DetailsCard(
        isMargin: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppDimens.spacingMedium,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppDimens.spacingExtraSmall,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(monthLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (income == null)
              Text(context.l10n.analysisRecurringBudgetRatesUnavailable)
            else
              _BudgetWaterfall(
                income: income,
                charges: budget.charges,
                totalCharges: budget.totalCharges,
                remaining: remaining,
                currency: currency,
              ),
          ],
        ),
      ),
    );
  }
}

String _budgetAmount(BuildContext context, double amount, String currency) =>
    NumberFormatUtils.formatCurrency(
      amount,
      currencyCode: currency,
      locale: Localizations.localeOf(context).toLanguageTag(),
    );

Future<void> _showBudgetCharges(
  BuildContext context,
  String title,
  List<RecurringBudgetCharge> charges,
) => showCustomBottomSheet<void>(
  context: context,
  minHeight: 0.3,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppDimens.spacingMedium,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      for (final charge in charges)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimens.spacingSmall,
          children: [
            Expanded(child: Text(charge.title)),
            Flexible(
              child: Text(
                _budgetAmount(context, charge.originalAmount, charge.currency),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      AppDimens.spacerMedium,
    ],
  ),
);
