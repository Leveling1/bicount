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

  Future<void> _openMenu(BuildContext context) async {
    final surface = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    RelativeRect position() => RelativeRect.fromSize(
      surface.localToGlobal(Offset.zero, ancestor: overlay) & surface.size,
      overlay.size,
    );

    var anchor = position();
    final selected = await showMenu<int>(
      context: context,
      positionBuilder: (_, _) {
        if (surface.attached && overlay.attached) anchor = position();
        return anchor;
      },
      items: [
        for (final option in options.entries)
          AppPopupMenuItem(
            value: option.key,
            selected: option.key == value,
            child: Text(option.value),
          ),
      ],
    );
    if (context.mounted && selected != null && selected != value) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      child: BicountPressable(
        onTap: () => _openMenu(context),
        color: theme.scaffoldBackgroundColor,
        customBorder: appPressShape,
        clipBehavior: Clip.antiAlias,
        scaleContentOnly: true,
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
    );
  }
}
