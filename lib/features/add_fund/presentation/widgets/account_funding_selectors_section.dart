import 'package:bicount/core/constants/dropdown_menu_entry.dart';
import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class AccountFundingSelectorsSection extends StatelessWidget {
  const AccountFundingSelectorsSection({
    super.key,
    required this.selectedFundingType,
    required this.isRecurring,
    required this.selectedFrequency,
    required this.salaryProcessingMode,
    required this.salaryReminderEnabled,
    this.allowRecurring = true,
    required this.onFundingTypeChanged,
    required this.onRecurringChanged,
    required this.onFrequencyChanged,
    required this.onSalaryProcessingModeChanged,
    required this.onSalaryReminderChanged,
  });

  final int selectedFundingType;
  final bool isRecurring;
  final int? selectedFrequency;
  final int salaryProcessingMode;
  final bool salaryReminderEnabled;
  final bool allowRecurring;
  final ValueChanged<int?> onFundingTypeChanged;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<int?> onFrequencyChanged;
  final ValueChanged<int> onSalaryProcessingModeChanged;
  final ValueChanged<bool> onSalaryReminderChanged;

  @override
  Widget build(BuildContext context) {
    final showSalaryControls =
        isRecurring && selectedFundingType == AccountFundingType.salary;
    final requiresConfirmation = SalaryProcessingMode.requiresConfirmation(
      salaryProcessingMode,
    );

    return Column(
      children: [
        if (allowRecurring)
          CheckboxListTile(
            value: isRecurring,
            onChanged: (value) => onRecurringChanged(value ?? false),
            title: Text(
              context.l10n.accountFundingRepeatLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        if (isRecurring) ...[
          AppDimens.spacerSmall,
          CustomDropdownMenu(
            title: context.l10n.commonFrequency,
            hintText: context.l10n.accountFundingFrequencyHint,
            initialValue: selectedFrequency,
            menuEntries: DropdownMenuEntryConstants.frequencyEntries(context),
            onChanged: onFrequencyChanged,
          ),
          if (showSalaryControls) ...[
            AppDimens.spacerMedium,
            SwitchListTile.adaptive(
              value: requiresConfirmation,
              onChanged: (value) => onSalaryProcessingModeChanged(
                value
                    ? SalaryProcessingMode.confirmationRequired
                    : SalaryProcessingMode.automatic,
              ),
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
                value: salaryReminderEnabled,
                onChanged: onSalaryReminderChanged,
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
        ],
      ],
    );
  }
}
