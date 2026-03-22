import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  const Separator({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, endIndent: 14)),
        Text('or', style: Theme.of(context).textTheme.bodySmall),
        Expanded(child: Divider(color: dividerColor, indent: 14)),
      ],
    );
  }
}
