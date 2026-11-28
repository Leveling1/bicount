part of 'analysis_recurring_budget_section.dart';

class _BudgetPeriodMenu extends StatelessWidget {
  const _BudgetPeriodMenu({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: appPressShape,
      clipBehavior: Clip.antiAlias,
      child: BicountPressable.control(
        child: PopupMenuButton<int>(
          tooltip: title,
          initialValue: value,
          onSelected: onChanged,
          itemBuilder: (context) => [
            for (final option in options.entries)
              AppPopupMenuItem(value: option.key, child: Text(option.value)),
          ],
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingSmall),
            child: Row(
              spacing: AppDimens.spacingSmall,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodySmall),
                      Text(options[value]!),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
