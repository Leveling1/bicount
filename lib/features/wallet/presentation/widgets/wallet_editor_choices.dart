part of 'wallet_editor.dart';

class _WalletIconChoices<T> extends StatelessWidget {
  const _WalletIconChoices({
    required this.title,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T selected;
  final List<({T value, String label, String? svg})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingSmall,
      children: [
        Padding(
          padding: WalletEditorLayout.horizontalInset,
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: WalletEditorLayout.horizontalInset,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimens.spacingExtraSmall,
            children: [
              for (final option in options) _buildOption(context, option),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    ({T value, String label, String? svg}) option,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = selected == option.value;
    final muted = Color.alphaBlend(
      colors.onSurface.withValues(alpha: .60),
      theme.scaffoldBackgroundColor,
    );
    final iconColor = isSelected ? Colors.black87 : muted;
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        onTap: () => onChanged(option.value),
        child: SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingExtraSmall),
            child: Column(
              spacing: AppDimens.spacingSmall,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFF5F5F5)
                        : Color.alphaBlend(
                            colors.onSurface.withValues(alpha: .08),
                            theme.scaffoldBackgroundColor,
                          ),
                  ),
                  child: option.svg == null
                      ? Icon(Icons.remove, size: 22, color: iconColor)
                      : SvgPicture.asset(
                          option.svg!,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                          excludeFromSemantics: true,
                        ),
                ),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? colors.onSurface : muted,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletColorChoices extends StatelessWidget {
  const _WalletColorChoices({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final names = [
      l10n.walletColorSilver,
      l10n.walletColorBlue,
      l10n.walletColorTeal,
      l10n.walletColorLavender,
      l10n.walletColorGold,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.spacingSmall,
      children: [
        Text(l10n.walletColor, style: theme.textTheme.titleMedium),
        Wrap(
          spacing: AppDimens.spacingSmall,
          runSpacing: AppDimens.spacingSmall,
          children: [
            for (final (index, name) in names.indexed)
              Semantics(
                label: name,
                button: true,
                selected: index == selected,
                child: Tooltip(
                  message: name,
                  excludeFromSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusMedium,
                    ),
                    onTap: () => onChanged(index),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: index == selected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: index == selected ? 2 : 1,
                        ),
                        gradient: walletFinishGradient(
                          walletFinishColor(index),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: index == selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF25231F),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(names[selected], style: theme.textTheme.labelMedium),
      ],
    );
  }
}
