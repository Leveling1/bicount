import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class SettingsOptionSheet<T> extends StatelessWidget {
  const SettingsOptionSheet({
    super.key,
    required this.title,
    required this.description,
    required this.selectedValue,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String title;
  final String description;
  final T selectedValue;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final Future<void> Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        AppDimens.spacerSmall,
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        AppDimens.spacerMedium,
        ...options.map(
          (option) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(labelBuilder(option)),
            trailing: option == selectedValue
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () async {
              await onSelected(option);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        AppDimens.spacerMedium,
      ],
    );
  }
}
