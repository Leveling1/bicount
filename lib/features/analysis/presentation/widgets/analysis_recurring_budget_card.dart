import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_budget.dart';
import 'package:flutter/material.dart';

part 'analysis_recurring_budget_waterfall.dart';
part 'analysis_recurring_budget_bar_row.dart';

class AnalysisRecurringBudgetCard extends StatelessWidget {
  const AnalysisRecurringBudgetCard({
    super.key,
    required this.budget,
    required this.currency,
    required this.precision,
  });

  final AnalysisRecurringBudget budget;
  final String currency;
  final int precision;

  @override
  Widget build(BuildContext context) {
    final income = budget.income;
    if (income == null) {
      return Text(context.l10n.analysisRecurringBudgetRatesUnavailable);
    }
    final difference = income - budget.totalCharges;
    final roundTo = math.pow(10, precision.clamp(0, 4));
    final remaining = (difference * roundTo).abs() < 0.5 ? 0.0 : difference;
    return _BudgetWaterfall(
      income: income,
      receivedIncome: budget.receivedIncome,
      plannedIncome: budget.plannedIncome,
      charges: budget.charges,
      totalCharges: budget.totalCharges,
      remaining: remaining,
      currency: currency,
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
