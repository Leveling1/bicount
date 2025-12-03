import 'package:bicount/core/constants/subscription_const.dart';
import 'package:flutter/material.dart';

class DropdownMenuEntryConstants {
  static List<DropdownMenuEntry<int>> frequencyEntries(BuildContext context) =>
      [
        DropdownMenuEntry(
          value: Frequency.weekly,
          label: 'Weekly',
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.monthly,
          label: 'Monthly',
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.quarterly,
          label: 'Quarterly',
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        DropdownMenuEntry(
          value: Frequency.yearly,
          label: 'Yearly',
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
      ];
}
