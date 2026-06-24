import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SemiDonutChartData {
  const SemiDonutChartData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class SemiDonutPackageChart extends StatelessWidget {
  const SemiDonutPackageChart({
    super.key,
    required this.sections,
    required this.centerText,
    this.centerSubtitle,
    this.height = 190, // On garde vos dimensions d'origine
  });

  final List<SemiDonutChartData> sections;
  final String centerText;
  final String? centerSubtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final centerContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            centerText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (centerSubtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            centerSubtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SfCircularChart(
            margin: EdgeInsets.zero,
            centerY: '90%',
            series: <CircularSeries>[
              DoughnutSeries<SemiDonutChartData, String>(
                dataSource: sections,
                xValueMapper: (SemiDonutChartData data, _) => data.label,
                yValueMapper: (SemiDonutChartData data, _) => data.value,
                pointColorMapper: (SemiDonutChartData data, _) => data.color,
                startAngle: 270,
                endAngle: 90,
                innerRadius: '80%',
                radius: '150%',
                strokeColor: theme.colorScheme.surface,
                strokeWidth: 4,
              ),
            ],
          ),
          Positioned(
            top: 
            105,
            child: IgnorePointer(child: centerContent),
          ),
        ],
      ),
    );
  }
}
