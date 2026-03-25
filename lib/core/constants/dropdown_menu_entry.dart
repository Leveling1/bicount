import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class DropdownMenuEntryConstants {
  static List<DropdownMenuEntry<int>> accountFundingTypeEntries(
    BuildContext context,
  ) => [
    DropdownMenuEntry(
      value: AccountFundingType.salary,
      label: context.accountFundingTypeLabel(AccountFundingType.salary),
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
    DropdownMenuEntry(
      value: AccountFundingType.other,
      label: context.accountFundingTypeLabel(AccountFundingType.other),
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
  ];

  static List<DropdownMenuEntry<int>> frequencyEntries(BuildContext context) =>
      [
        DropdownMenuEntry(
          value: Frequency.weekly,
          label: context.frequencyLabel(Frequency.weekly),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.monthly,
          label: context.frequencyLabel(Frequency.monthly),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.quarterly,
          label: context.frequencyLabel(Frequency.quarterly),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.yearly,
          label: context.frequencyLabel(Frequency.yearly),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
      ];
}
