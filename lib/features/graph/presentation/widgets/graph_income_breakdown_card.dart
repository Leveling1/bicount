import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphIncomeBreakdownCard extends StatelessWidget {
  const GraphIncomeBreakdownCard({super.key, required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).extension<OtherTheme>()!.personnalIncome!,
      AppColors.secondaryColorBasic,
      AppColors.quaternaryColorBasic,
    ];

    return DetailsCard(
      child: dashboard.incomeBreakdown.isEmpty
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
                SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 52,
                      sectionsSpace: 2,
                      sections: dashboard.incomeBreakdown.asMap().entries.map((
                        entry,
                      ) {
                        final total = dashboard.incomeBreakdown.fold<double>(
                          0,
                          (sum, item) => sum + item.value,
                        );
                        final percent = total == 0
                            ? 0.0
                            : (entry.value.value / total) * 100;
                        return PieChartSectionData(
                          value: entry.value.value,
                          color: colors[entry.key % colors.length],
                          radius: 42,
                          title: '${percent.toStringAsFixed(0)}%',
                          titleStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.marginMedium),
                ...dashboard.incomeBreakdown.asMap().entries.map((entry) {
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
                            context.graphBreakdownLabel(entry.value.label),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          NumberFormatUtils.formatCurrency(entry.value.value),
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
