part of 'analysis_recurring_calendar.dart';

extension on RecurringPlanScope {
  Color agendaColor(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<OtherTheme>()!;
    return this == RecurringPlanScope.income ? colors.income! : colors.expense!;
  }

  String agendaLabel(BuildContext context) => this == RecurringPlanScope.income
      ? context.l10n.analysisIncome
      : context.l10n.analysisExpenses;
}

class _AgendaDay extends StatelessWidget {
  const _AgendaDay({
    super.key,
    required this.day,
    required this.selected,
    required this.scopes,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final Set<RecurringPlanScope> scopes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Semantics(
      label: [
        material.formatFullDate(day),
        for (final scope in scopes) scope.agendaLabel(context),
      ].join(', '),
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: BicountPressable(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: AppSizes.dp44,
          child: Center(
            child: Ink(
              width: AppSizes.dp36,
              height: AppSizes.dp36,
              decoration: BoxDecoration(
                color: selected ? primary.withValues(alpha: .16) : null,
                border: selected ? Border.all(color: primary) : null,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        material.formatDecimal(day.day),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSizes.dp6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppDimens.spacingExtraSmall,
                      children: [
                        for (final scope in scopes) _AgendaMarker(scope),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaMarker extends StatelessWidget {
  const _AgendaMarker(this.scope);

  final RecurringPlanScope scope;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: scope.agendaColor(context),
    ),
    child: const SizedBox.square(dimension: AppSizes.dp6),
  );
}

class _AgendaEntry extends StatelessWidget {
  const _AgendaEntry(this.entry);

  final AnalysisRecurringEntry entry;

  @override
  Widget build(BuildContext context) {
    final plan = entry.plan;
    final planId = plan.recurringTransfertId;
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: BicountPressable(
        customBorder: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
        onTap: planId == null || planId.isEmpty
            ? null
            : () => showRecurringPlanDetailSheet(
                context,
                scope: entry.scope,
                recurringTransfertId: planId,
              ),
        child: Row(
          spacing: AppDimens.spacingSmall,
          children: [
            _AgendaMarker(entry.scope),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.title, style: theme.textTheme.titleSmall),
                  Text(
                    entry.scope.agendaLabel(context),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                NumberFormatUtils.formatCurrency(
                  plan.amount,
                  currencyCode: plan.currency,
                  locale: Localizations.localeOf(context).toString(),
                ),
                textAlign: TextAlign.end,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
