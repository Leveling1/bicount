part of 'analysis_recurring_budget_card.dart';

class _BudgetWaterfall extends StatelessWidget {
  const _BudgetWaterfall({
    required this.income,
    required this.receivedIncome,
    required this.plannedIncome,
    required this.charges,
    required this.totalCharges,
    required this.remaining,
    required this.currency,
  });

  final double income;
  final double? receivedIncome;
  final double? plannedIncome;
  final List<RecurringBudgetCharge> charges;
  final double totalCharges;
  final double remaining;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OtherTheme>()!;
    final l10n = context.l10n;
    final received = receivedIncome;
    final planned = plannedIncome;
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
          received == null
              ? l10n.analysisRecurringIncomesTitle
              : planned == null
              ? l10n.analysisRecurringBudgetReceivedIncome
              : l10n.analysisRecurringBudgetTotalIncome,
          0,
          income,
          income,
          colors.income!,
          sign: '+ ',
        ),
        if (received != null && planned != null)
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingExtraSmall,
            children: [
              Text(
                '${l10n.analysisRecurringBudgetReceivedIncome} · ${_budgetAmount(context, received, currency)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${l10n.analysisRecurringIncomesTitle} · ${_budgetAmount(context, planned, currency)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
