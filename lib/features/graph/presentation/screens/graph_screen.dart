import 'package:bicount/core/themes/app_dimens.dart';
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
                state.errorMessage ?? 'Unable to load analytics',
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
                Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimens.marginSmall),
                Text(
                  'Track your flow, spot your recurring costs and keep the useful signals close.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                GraphPeriodSelector(
                  selectedPeriod: state.period,
                  onSelected: (period) {
                    context.read<GraphBloc>().add(GraphPeriodChanged(period));
                  },
                ),
                const SizedBox(height: AppDimens.marginLarge),
                GraphMetricOverview(dashboard: dashboard),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Cashflow trend',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GraphCashflowChart(dashboard: dashboard),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Expense mix',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GraphExpenseBreakdownCard(dashboard: dashboard),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Subscriptions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GraphSubscriptionInsightCard(dashboard: dashboard),
              ],
            ),
          ),
        );
      },
    );
  }
}
