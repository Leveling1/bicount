import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  const Separator({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;
    final label = context.l10n.commonOr;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 26, child: Divider(color: dividerColor)),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 10),
          SizedBox(width: 26, child: Divider(color: dividerColor)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, endIndent: 14)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Expanded(child: Divider(color: dividerColor, indent: 14)),
      ],
    );
  }
}
