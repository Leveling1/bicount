import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/core/widgets/half_donut_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_contact_category_sheet.dart';
import 'package:flutter/material.dart';

class AnalysisBreakdownCard extends StatelessWidget {
  const AnalysisBreakdownCard({
    super.key,
    required this.chart,
    required this.breakdown,
    required this.currencyCode,
    required this.colors,
  });

  final AnalysisChart chart;
  final List<AnalysisBreakdownItem> breakdown;
  final String currencyCode;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (breakdown.isEmpty)
            Padding(
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
          else
            HalfDonutChart(
              segments: [
                for (final (index, item) in breakdown.indexed)
                  ChartSegment(
                    label: item.friendSid == null
                        ? context.analysisBreakdownLabel(item.label)
                        : item.label,
                    value: item.value,
                    displayCurrencyCode: currencyCode,
                    color: colors[index % colors.length],
                  ),
              ],
              total: breakdown.fold<double>(0, (sum, item) => sum + item.value),
              currencyCode: currencyCode,
            ),
          Positioned(
            top: 0,
            right: 0,
            child: BicountPressable.button(
              builder: (statesController) => IconButton(
                statesController: statesController,
                tooltip: context.l10n.analysisContactCategories,
                onPressed: () => showAnalysisContactCategories(context, chart),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
