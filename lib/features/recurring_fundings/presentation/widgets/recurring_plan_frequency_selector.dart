part of 'recurring_plan_form.dart';

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _frequencies = [
    Frequency.weekly,
    Frequency.monthly,
    Frequency.quarterly,
    Frequency.yearly,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.commonFrequency,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: AppDimens.spacingSmall,
            children: _frequencies.map((frequency) {
              return CustomChoiceChip(
                label: context.frequencyLabel(frequency),
                selected: selected == frequency,
                onSelected: (_) => onChanged(frequency),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
