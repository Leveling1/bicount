import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/semi_donut_package_chart.dart';
import 'package:flutter/material.dart';

class AnalysisExpenseBreakdownCard extends StatelessWidget {
  const AnalysisExpenseBreakdownCard({super.key, required this.dashboard});

  final AnalysisDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final breakdown = dashboard.expenseBreakdown;
    final total = breakdown.fold<double>(0, (sum, item) => sum + item.value);
    final colors = [
      Theme.of(context).extension<OtherTheme>()!.expense!,
      AppColors.quaternaryColorBasic,
      Colors.orange,
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
          : Column(
              children: [
                SemiDonutPackageChart(
                  sections: breakdown.asMap().entries.map((entry) {
                    return SemiDonutChartData(
                      label: entry.value.label,
                      value: entry.value.value,
                      color: colors[entry.key % colors.length],
                    );
                  }).toList(),
                  centerText: NumberFormatUtils.formatCurrency(
                    total,
                    currencyCode: dashboard.displayCurrencyCode,
                  ),
                ),
                ...breakdown.asMap().entries.map((entry) {
                  final color = colors[entry.key % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.analysisBreakdownLabel(entry.value.label),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          NumberFormatUtils.formatCurrency(
                            entry.value.value,
                            currencyCode: dashboard.displayCurrencyCode,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
