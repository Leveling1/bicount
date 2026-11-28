import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_breakdown_card.dart';
import 'package:flutter/material.dart';

class AnalysisExpenseBreakdownCard extends StatelessWidget {
  const AnalysisExpenseBreakdownCard({super.key, required this.dashboard});

  final AnalysisDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<OtherTheme>()!;
    final colors = [
      theme.analysisExpense!,
      theme.analysisSubscription!,
      theme.analysisDebt!,
      theme.analysisRepayment!,
      theme.analysisOther!,
    ];

    return AnalysisBreakdownCard(
      chart: AnalysisChart.expense,
      breakdown: dashboard.expenseBreakdown,
      currencyCode: dashboard.displayCurrencyCode,
      colors: colors,
    );
  }
}
