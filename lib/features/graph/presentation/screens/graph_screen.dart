import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/graph/presentation/bloc/graph_bloc.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_cashflow_chart.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_expense_breakdown_card.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_metric_card.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_period_selector.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_subscription_insight_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      builder: (context, state) {
        if (state.status == GraphStatus.loading && state.dashboard == null) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Theme.of(context).primaryColor,
              size: 36,
            ),
          );
        }

        if (state.status == GraphStatus.failure && state.dashboard == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Text(
                state.errorMessage ?? context.l10n.graphUnableToLoad,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final dashboard = state.dashboard;
        if (dashboard == null) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SingleChildScrollView(
            key: ValueKey(state.period),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingMedium,
              AppDimens.paddingLarge,
              AppDimens.paddingMedium,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BicountReveal(
                  delay: const Duration(milliseconds: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.graphOverview,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimens.marginSmall),
                      Text(
                        context.l10n.graphOverviewDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.marginLarge),
                BicountReveal(
                  delay: const Duration(milliseconds: 90),
                  child: GraphPeriodSelector(
                    selectedPeriod: state.period,
                    onSelected: (period) {
                      context.read<GraphBloc>().add(GraphPeriodChanged(period));
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.marginLarge),
                BicountReveal(
                  delay: const Duration(milliseconds: 140),
                  child: GraphMetricOverview(dashboard: dashboard),
                ),
                const SizedBox(height: AppDimens.marginLarge),
                BicountReveal(
                  delay: const Duration(milliseconds: 190),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.graphCashflowTrend,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      GraphCashflowChart(dashboard: dashboard),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.marginLarge),
                BicountReveal(
                  delay: const Duration(milliseconds: 230),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.graphExpenseMix,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      GraphExpenseBreakdownCard(dashboard: dashboard),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.marginLarge),
                BicountReveal(
                  delay: const Duration(milliseconds: 270),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.graphSubscriptions,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      GraphSubscriptionInsightCard(dashboard: dashboard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
