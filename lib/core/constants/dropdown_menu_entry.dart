import 'package:bicount/core/constants/subscription_const.dart';
import 'package:flutter/material.dart';

class DropdownMenuEntryConstants {
  static List<DropdownMenuEntry<int>> frequencyEntries(BuildContext context) => [
    DropdownMenuEntry(
      value: SubscriptionFrequency.weekly,
      label: 'Weekly',
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
    DropdownMenuEntry(
      value: SubscriptionFrequency.monthly,
      label: 'Monthly',
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
    DropdownMenuEntry(
      value: SubscriptionFrequency.quarterly,
      label: 'Quarterly',
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
    DropdownMenuEntry(
      value: SubscriptionFrequency.yearly,
      label: 'Yearly',
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    ),
  ];
}
