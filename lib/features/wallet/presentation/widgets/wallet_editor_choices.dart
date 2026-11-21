part of 'wallet_editor.dart';

class _WalletEditorChoices extends StatelessWidget {
  const _WalletEditorChoices({
    required this.label,
    required this.selected,
    required this.icons,
    required this.onChanged,
  });

  final String label;
  final int selected;
  final List<Widget> icons;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: AppDimens.spacingSmall,
          children: [
            for (final (index, icon) in icons.indexed)
              ChoiceChip(
                label: icon,
                showCheckmark: false,
                selected: index == selected,
                onSelected: (_) => onChanged(index),
              ),
          ],
        ),
      ],
    );
  }
}
