import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
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
    this.salaryRequiresConfirmation,
    this.salaryReminderEnabled,
    this.onSalaryRequiresConfirmationChanged,
    this.onSalaryReminderChanged,
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
  final bool? salaryRequiresConfirmation;
  final bool? salaryReminderEnabled;
  final ValueChanged<bool>? onSalaryRequiresConfirmationChanged;
  final ValueChanged<bool>? onSalaryReminderChanged;

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
                  salaryRequiresConfirmation: salaryRequiresConfirmation,
                  salaryReminderEnabled: salaryReminderEnabled,
                  typeOptions: typeOptions,
                  onFrequencyChanged: onFrequencyChanged,
                  onTypeChanged: onTypeChanged,
                  onSalaryRequiresConfirmationChanged:
                      onSalaryRequiresConfirmationChanged,
                  onSalaryReminderChanged: onSalaryReminderChanged,
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
    this.salaryRequiresConfirmation,
    this.salaryReminderEnabled,
    this.onSalaryRequiresConfirmationChanged,
    this.onSalaryReminderChanged,
  });

  final int frequency;
  final int recurringTypeId;
  final List<int> typeOptions;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<int> onTypeChanged;
  final bool? salaryRequiresConfirmation;
  final bool? salaryReminderEnabled;
  final ValueChanged<bool>? onSalaryRequiresConfirmationChanged;
  final ValueChanged<bool>? onSalaryReminderChanged;

  @override
  Widget build(BuildContext context) {
    final showSalaryControls =
        recurringTypeId == TransactionTypes.salaryCode &&
        salaryRequiresConfirmation != null &&
        salaryReminderEnabled != null &&
        onSalaryRequiresConfirmationChanged != null &&
        onSalaryReminderChanged != null;

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
          if (showSalaryControls) ...[
            AppDimens.spacerMedium,
            _SalaryExecutionSection(
              requiresConfirmation: salaryRequiresConfirmation!,
              reminderEnabled: salaryReminderEnabled!,
              onRequiresConfirmationChanged:
                  onSalaryRequiresConfirmationChanged!,
              onReminderChanged: onSalaryReminderChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SalaryExecutionSection extends StatelessWidget {
  const _SalaryExecutionSection({
    required this.requiresConfirmation,
    required this.reminderEnabled,
    required this.onRequiresConfirmationChanged,
    required this.onReminderChanged,
  });

  final bool requiresConfirmation;
  final bool reminderEnabled;
  final ValueChanged<bool> onRequiresConfirmationChanged;
  final ValueChanged<bool> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          value: requiresConfirmation,
          onChanged: onRequiresConfirmationChanged,
          title: Text(
            context.l10n.salaryConfirmBeforeCountingTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            context.l10n.salaryConfirmBeforeCountingHelper,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        if (requiresConfirmation)
          SwitchListTile.adaptive(
            value: reminderEnabled,
            onChanged: onReminderChanged,
            title: Text(
              context.l10n.salaryReminderToggleTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              context.l10n.salaryReminderToggleHelper,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
          ),
      ],
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
            return CustomChoiceChip(
              label: context.frequencyLabel(freq),
              selected: isSelected,
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
            return CustomChoiceChip(
              label: TransactionTypes.typeLabel(context, typeId),
              selected: typeId == selected,
              onSelected: (_) => onChanged(typeId),
            );
          }).toList(),
        ),
      ],
    );
  }
}
