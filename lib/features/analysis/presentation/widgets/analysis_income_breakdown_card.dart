import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/core/widgets/half_donut_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:flutter/material.dart';

class AnalysisIncomeBreakdownCard extends StatelessWidget {
  const AnalysisIncomeBreakdownCard({super.key, required this.dashboard});

  final AnalysisDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final breakdown = dashboard.incomeBreakdown;
    final total = breakdown.fold<double>(0, (sum, item) => sum + item.value);
    final colors = [
      Theme.of(context).extension<OtherTheme>()!.personnalIncome!,
      AppColors.primaryColorBasic,
      AppColors.quaternaryColorBasic,
    ];

    return DetailsCard(
      child: breakdown.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingLarge,
              ),
              child: Center(
                child: Text(
                  context.l10n.transactionNoTransactionsFound,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          : HalfDonutChart(
              segments: breakdown.map((item) {
                return ChartSegment(
                  label: item.label,
                  value: item.value,
                  displayCurrencyCode: dashboard.displayCurrencyCode,
                  color: colors[breakdown.indexOf(item) % colors.length],
                );
              }).toList(),
              total: total,
              currencyCode: dashboard.displayCurrencyCode,
            ),
    );
  }
}
