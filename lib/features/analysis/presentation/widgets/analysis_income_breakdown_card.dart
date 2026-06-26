import 'package:bicount/core/localization/l10n_extensions.dart';
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
    final theme = Theme.of(context).extension<OtherTheme>()!;
    final colors = [
      theme.analysisRevenue!,
      theme.analysisSalary!,
      theme.analysisDebt!,
      theme.analysisRepayment!,
      theme.analysisOther!,
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
              segments: breakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return ChartSegment(
                  label: context.analysisBreakdownLabel(item.label),
                  value: item.value,
                  displayCurrencyCode: dashboard.displayCurrencyCode,
                  color: colors[index % colors.length],
                );
              }).toList(),
              total: total,
              currencyCode: dashboard.displayCurrencyCode,
            ),
    );
  }
}
