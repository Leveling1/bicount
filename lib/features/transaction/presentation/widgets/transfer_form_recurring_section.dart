import 'package:bicount/core/constants/recurring_transfert_type.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

/// Recurring toggle + animated frequency / type selectors shared by both
/// expense and income forms.
class TransferFormRecurringSection extends StatelessWidget {
  const TransferFormRecurringSection({
    super.key,
    required this.isRecurring,
    required this.frequency,
    required this.recurringTypeId,
    required this.typeOptions,
    required this.onRecurringChanged,
    required this.onFrequencyChanged,
    required this.onTypeChanged,
    required this.subtitle,
    this.enabled = true,
  });

  final bool isRecurring;
  final int frequency;
  final int recurringTypeId;
  final List<int> typeOptions;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<int> onTypeChanged;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: isRecurring,
          onChanged: enabled ? (v) => onRecurringChanged(v) : null,
          title: Text(
            context.l10n.recurringToggleTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isRecurring
              ? _RecurringOptions(
                  frequency: frequency,
                  recurringTypeId: recurringTypeId,
                  typeOptions: typeOptions,
                  onFrequencyChanged: onFrequencyChanged,
                  onTypeChanged: onTypeChanged,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _RecurringOptions extends StatelessWidget {
  const _RecurringOptions({
    required this.frequency,
    required this.recurringTypeId,
    required this.typeOptions,
    required this.onFrequencyChanged,
    required this.onTypeChanged,
  });

  final int frequency;
  final int recurringTypeId;
  final List<int> typeOptions;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<int> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FrequencySelector(
            selected: frequency,
            onChanged: onFrequencyChanged,
          ),
          AppDimens.spacerMedium,
          _TypeSelector(
            selected: recurringTypeId,
            options: typeOptions,
            onChanged: onTypeChanged,
          ),
        ],
      ),
    );
  }
}

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
          context.l10n.recurringFrequencyLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Wrap(
          spacing: AppDimens.spacingSmall,
          children: _frequencies.map((freq) {
            final isSelected = freq == selected;
            return ChoiceChip(
              label: Text(context.frequencyLabel(freq)),
              selected: isSelected,
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor,
              side: BorderSide.none,
              onSelected: (_) => onChanged(freq),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final int selected;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.recurringTypeLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Wrap(
          spacing: AppDimens.spacingSmall,
          children: options.map((typeId) {
            return ChoiceChip(
              label: Text(_typeLabel(context, typeId)),
              selected: typeId == selected,
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor,
              side: BorderSide.none,
              onSelected: (_) => onChanged(typeId),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _typeLabel(BuildContext context, int typeId) {
    switch (typeId) {
      case RecurringTransfertType.subscriptionExpense:
        return context.l10n.recurringTypeSubscription;
      case RecurringTransfertType.recurringExpenseOther:
        return context.l10n.recurringTypeOther;
      case RecurringTransfertType.salaryIncome:
        return context.l10n.recurringTypeSalary;
      case RecurringTransfertType.recurringIncomeOther:
        return context.l10n.recurringTypeOtherIncome;
      default:
        return context.l10n.recurringTypeOther;
    }
  }
}
