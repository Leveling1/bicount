import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/graph/presentation/bloc/graph_bloc.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_expense_breakdown_card.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_income_breakdown_card.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_period_selector.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_recurring_summary_card.dart';
import 'package:bicount/features/graph/presentation/widgets/graph_screen_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/graph_metric_overview.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      buildWhen: (previous, current) {
        final previousHasDashboard = previous.dashboard != null;
        final currentHasDashboard = current.dashboard != null;
        if (previousHasDashboard != currentHasDashboard) {
          return true;
        }
        if (!currentHasDashboard) {
          return previous.status != current.status ||
              previous.errorMessage != current.errorMessage;
        }
        return false;
      },
      builder: (context, state) {
        if (state.status == GraphStatus.loading && state.dashboard == null) {
          return const GraphScreenSkeleton();
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

        return const _GraphScreenContent();
      },
    );
  }
}

class _GraphScreenContent extends StatelessWidget {
  const _GraphScreenContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingLarge,
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
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
            child: BlocBuilder<GraphBloc, GraphState>(
              buildWhen: (previous, current) =>
                  previous.period != current.period,
              builder: (context, state) {
                return GraphPeriodSelector(
                  selectedPeriod: state.period,
                  onSelected: (period) {
                    context.read<GraphBloc>().add(GraphPeriodChanged(period));
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
          BlocBuilder<GraphBloc, GraphState>(
            buildWhen: (previous, current) =>
                previous.dashboard != current.dashboard,
            builder: (context, state) {
              final dashboard = state.dashboard;
              if (dashboard == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          context.l10n.graphIncome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        GraphIncomeBreakdownCard(dashboard: dashboard),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 210),
                    child: GraphRecurringSummaryCard(
                      title: context.l10n.graphRecurringChargesTitle,
                      description:
                          context.l10n.graphRecurringChargesDescription,
                      summary: dashboard.recurringCharges,
                      currencyCode: dashboard.displayCurrencyCode,
                      color: Theme.of(
                        context,
                      ).extension<OtherTheme>()!.expense!,
                      upcomingLabel: context.l10n.graphUpcomingCharges,
                      onTap: () => context.push('/subscriptions'),
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
                    delay: const Duration(milliseconds: 260),
                    child: GraphRecurringSummaryCard(
                      title: context.l10n.graphRecurringIncomesTitle,
                      description:
                          context.l10n.graphRecurringIncomesDescription,
                      summary: dashboard.recurringIncomes,
                      currencyCode: dashboard.displayCurrencyCode,
                      color: Theme.of(context).extension<OtherTheme>()!.income!,
                      upcomingLabel: context.l10n.graphRecurringIncomesUpcoming,
                      onTap: () => context.push('/recurring-incomes'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
