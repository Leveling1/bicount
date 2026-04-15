import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_expense_breakdown_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_income_breakdown_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_period_selector.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_summary_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_screen_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/analysis_metric_overview.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
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
        if (state.status == AnalysisStatus.loading && state.dashboard == null) {
          return const AnalysisScreenSkeleton();
        }

        if (state.status == AnalysisStatus.failure && state.dashboard == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Text(
                state.errorMessage ?? context.l10n.analysisUnableToLoad,
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

        return const _AnalysisScreenContent();
      },
    );
  }
}

class _AnalysisScreenContent extends StatelessWidget {
  const _AnalysisScreenContent();

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
                  context.l10n.analysisOverview,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.marginSmall),
                Text(
                  context.l10n.analysisOverviewDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
          BicountReveal(
            delay: const Duration(milliseconds: 90),
            child: BlocBuilder<AnalysisBloc, AnalysisState>(
              buildWhen: (previous, current) =>
                  previous.period != current.period,
              builder: (context, state) {
                return AnalysisPeriodSelector(
                  selectedPeriod: state.period,
                  onSelected: (period) {
                    context.read<AnalysisBloc>().add(
                      AnalysisPeriodChanged(period),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
          BlocBuilder<AnalysisBloc, AnalysisState>(
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
                    child: AnalysisMetricOverview(dashboard: dashboard),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 190),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.analysisIncome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AnalysisIncomeBreakdownCard(dashboard: dashboard),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 260),
                    child: AnalysisRecurringSummaryCard(
                      title: context.l10n.analysisRecurringIncomesTitle,
                      description:
                          context.l10n.analysisRecurringIncomesDescription,
                      summary: dashboard.recurringIncomes,
                      currencyCode: dashboard.displayCurrencyCode,
                      color: Theme.of(context).extension<OtherTheme>()!.income!,
                      upcomingLabel:
                          context.l10n.analysisRecurringIncomesUpcoming,
                      onTap: () => context.push('/recurring-incomes'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 230),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.analysisExpenseMix,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AnalysisExpenseBreakdownCard(dashboard: dashboard),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 210),
                    child: AnalysisRecurringSummaryCard(
                      title: context.l10n.analysisRecurringChargesTitle,
                      description:
                          context.l10n.analysisRecurringChargesDescription,
                      summary: dashboard.recurringCharges,
                      currencyCode: dashboard.displayCurrencyCode,
                      color: Theme.of(
                        context,
                      ).extension<OtherTheme>()!.expense!,
                      upcomingLabel: context.l10n.analysisUpcomingCharges,
                      onTap: () => context.push('/subscriptions'),
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
