import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_breakdown_card.dart';
import 'package:flutter/material.dart';

class AnalysisIncomeBreakdownCard extends StatelessWidget {
  const AnalysisIncomeBreakdownCard({super.key, required this.dashboard});

  final AnalysisDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<OtherTheme>()!;
    final colors = [
      theme.analysisRevenue!,
      theme.analysisSalary!,
      theme.analysisDebt!,
      theme.analysisRepayment!,
      theme.analysisOther!,
    ];

    return AnalysisBreakdownCard(
      chart: AnalysisChart.income,
      breakdown: dashboard.incomeBreakdown,
      currencyCode: dashboard.displayCurrencyCode,
      colors: colors,
    );
  }
}
