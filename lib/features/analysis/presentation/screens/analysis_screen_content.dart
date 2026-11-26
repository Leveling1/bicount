part of 'analysis_screen.dart';

class _AnalysisScreenContent extends StatelessWidget {
  const _AnalysisScreenContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header (title + description) — scrolls away ──
        /*SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingMedium,
            AppDimens.paddingLarge,
            AppDimens.paddingMedium,
            AppDimens.marginLarge,
          ),
          sliver: SliverToBoxAdapter(
            child: BicountReveal(
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
          ),
        ),*/
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocSelector<MainBloc, MainState, List<RecurringTransfertModel>>(
                selector: (state) => state is MainLoaded
                    ? state.startData.recurringTransferts
                    : const [],
                builder: (context, plans) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.marginLarge),
                  child: AnalysisRecurringCalendar(
                    plans: plans,
                    monthFooterBuilder: (context, month, entries) =>
                        AnalysisRecurringBudgetCard(
                          month: month,
                          agenda: entries,
                        ),
                  ),
                ),
              ),
              if (BackendEnvironment.isLocalPreproduction)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: AnalysisWalletDistributionCard(),
                ), 
            ],
          ),
        ),

        // ── Period selector — PINNED ──
        SliverPersistentHeader(
          pinned: true,
          delegate: PinnedHeaderDelegate(
            padding: EdgeInsets.zero,
            child: BicountReveal(
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
          ),
        ),

        // ── Rest of the content ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingMedium,
            AppDimens.marginLarge,
            AppDimens.paddingMedium,
            AppDimens.paddingMedium,
          ),
          sliver: SliverToBoxAdapter(
            child: BlocBuilder<AnalysisBloc, AnalysisState>(
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
                    BicountReveal(
                      delay: const Duration(milliseconds: 260),
                      child: AnalysisRecurringSummaryCard(
                        title: context.l10n.analysisRecurringIncomesTitle,
                        description:
                            context.l10n.analysisRecurringIncomesDescription,
                        summary: dashboard.recurringIncomes,
                        currencyCode: dashboard.displayCurrencyCode,
                        color: Theme.of(
                          context,
                        ).extension<OtherTheme>()!.income!,
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
          ),
        ),
      ],
    );
  }
}
