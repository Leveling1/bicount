part of 'analysis_recurring_budget_card.dart';

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
                  size: AppSizes.dp18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                height: AppSizes.dp9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusSmall,
                        ),
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
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSmall,
                            ),
                            color: color,
                          ),
                        ),
                      ),
                    if (zero > 0 && zero < 1)
                      PositionedDirectional(
                        start: zero * width,
                        top: 0,
                        bottom: 0,
                        width: AppSizes.dp1,
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
            child: BicountPressable(
              customBorder: appPressShape,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSizes.dp48),
                child: content,
              ),
            ),
          );
  }
}
