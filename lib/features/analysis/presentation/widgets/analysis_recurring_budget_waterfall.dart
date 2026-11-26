part of 'analysis_recurring_budget_card.dart';

class _BudgetWaterfall extends StatelessWidget {
  const _BudgetWaterfall({
    required this.income,
    required this.charges,
    required this.totalCharges,
    required this.remaining,
    required this.currency,
  });

  final double income;
  final List<RecurringBudgetCharge> charges;
  final double totalCharges;
  final double remaining;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OtherTheme>()!;
    final l10n = context.l10n;
    final visible = charges.take(3);
    final other = charges.skip(3).toList(growable: false);
    final balanceColor = remaining < 0
        ? colors.expense!
        : Theme.of(context).colorScheme.primary;
    final balanceLabel = remaining < 0
        ? l10n.analysisRecurringBudgetDeficit
        : l10n.analysisRecurringBudgetRemaining;

    final lower = math.min(0.0, remaining);
    final range = income - lower;
    double fraction(double amount) =>
        range == 0 ? 0 : ((amount - lower) / range).clamp(0.0, 1.0).toDouble();
    var running = income;

    Widget row(
      String label,
      double start,
      double end,
      double amount,
      Color color, {
      String sign = '',
      VoidCallback? onTap,
    }) => _BudgetBarRow(
      label: label,
      amount: '$sign${_budgetAmount(context, amount, currency)}',
      from: fraction(math.min(start, end)),
      to: fraction(math.max(start, end)),
      zero: fraction(0),
      color: color,
      onTap: onTap,
    );

    Widget chargeRow(String title, double amount, {VoidCallback? onTap}) {
      final start = running;
      running -= amount;
      return row(
        title,
        start,
        running,
        amount,
        colors.expense!,
        sign: '− ',
        onTap: onTap,
      );
    }

    final amountStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(color: balanceColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingSmall,
      children: [
        Text(balanceLabel, style: Theme.of(context).textTheme.bodyMedium),
        Text(_budgetAmount(context, remaining, currency), style: amountStyle),
        Text(
          '${l10n.analysisRecurringChargesTitle} · ${_budgetAmount(context, totalCharges, currency)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimens.spacingExtraSmall),
        row(
          l10n.analysisRecurringIncomesTitle,
          0,
          income,
          income,
          colors.income!,
          sign: '+ ',
        ),
        for (final charge in visible)
          chargeRow(
            charge.title,
            charge.amount,
            onTap: charge.currency.toUpperCase() == currency.toUpperCase()
                ? null
                : () => _showBudgetCharges(context, charge.title, [charge]),
          ),
        if (other.isNotEmpty)
          chargeRow(
            l10n.analysisRecurringBudgetOtherCharges,
            other.fold(0.0, (sum, charge) => sum + charge.amount),
            onTap: () => _showBudgetCharges(
              context,
              l10n.analysisRecurringBudgetOtherCharges,
              other,
            ),
          ),
        row(balanceLabel, 0, remaining, remaining, balanceColor),
      ],
    );
  }
}

class _BudgetBarRow extends StatelessWidget {
  const _BudgetBarRow({
    required this.label,
    required this.amount,
    required this.from,
    required this.to,
    required this.zero,
    required this.color,
    this.onTap,
  });

  final String label;
  final String amount;
  final double from;
  final double to;
  final double zero;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.spacingExtraSmall,
      ),
      child: Column(
        spacing: AppDimens.spacingExtraSmall,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimens.spacingSmall,
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              Flexible(
                child: Text(
                  amount,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.end,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                height: 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.07,
                        ),
                      ),
                    ),
                    if (to > from)
                      PositionedDirectional(
                        start: from * width,
                        width: (to - from) * width,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: color,
                          ),
                        ),
                      ),
                    if (zero > 0 && zero < 1)
                      PositionedDirectional(
                        start: zero * width,
                        top: 0,
                        bottom: 0,
                        width: 1,
                        child: ColoredBox(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    return onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: content,
              ),
            ),
          );
  }
}
