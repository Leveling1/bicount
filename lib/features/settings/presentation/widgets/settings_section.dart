import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sectionChildren = children.asMap().entries.expand<Widget>((
      entry,
    ) sync* {
      yield entry.value;
      if (entry.key != children.length - 1) {
        yield Divider(color: Theme.of(context).dividerColor, height: 10);
      }
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        DetailsCard(child: Column(children: sectionChildren)),
      ],
    );
  }
}
