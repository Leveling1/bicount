import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalysisCashflowChart extends StatelessWidget {
  const AnalysisCashflowChart({super.key, required this.dashboard});

  final AnalysisDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    if (dashboard.cashflowPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final lineColor = Theme.of(context).primaryColor;
    final minValue = dashboard.cashflowPoints
        .map((point) => point.cumulativeNet)
        .reduce((left, right) => left < right ? left : right);
    final maxValue = dashboard.cashflowPoints
        .map((point) => point.cumulativeNet)
        .reduce((left, right) => left > right ? left : right);

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cumulative net',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                dashboard.period.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.marginLarge),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minValue > 0 ? 0 : minValue * 1.15,
                maxY: maxValue <= 0 ? 0 : maxValue * 1.15,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: ((maxValue - minValue).abs() / 4).clamp(
                    20,
                    5000,
                  ),
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.18),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            NumberFormatUtils.compactCurrency(value),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _bottomInterval(
                        dashboard.cashflowPoints.length,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= dashboard.cashflowPoints.length) {
                          return const SizedBox.shrink();
                        }
                        final point = dashboard.cashflowPoints[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dashboard.period == AnalysisPeriod.all
                                ? DateFormat('MMM yy').format(point.date)
                                : DateFormat('dd MMM').format(point.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dashboard.cashflowPoints.asMap().entries.map((
                      entry,
                    ) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.cumulativeNet,
                      );
                    }).toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _bottomInterval(int length) {
    if (length <= 7) {
      return 1;
    }
    if (length <= 15) {
      return 3;
    }
    if (length <= 35) {
      return 6;
    }
    final interval = (length / 5).floorToDouble();
    return interval < 1 ? 1 : interval;
  }
}
