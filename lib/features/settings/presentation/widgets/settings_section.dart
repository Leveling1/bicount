import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

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
      yield SettingsOptionInsets(
        padding: EdgeInsets.only(
          top: entry.key == 0 ? AppDimens.paddingMedium : 0,
          bottom: entry.key == children.length - 1
              ? AppDimens.paddingMedium
              : 0,
        ),
        child: entry.value,
      );
      if (entry.key != children.length - 1) {
        yield Divider(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          indent: AppDimens.paddingMedium,
          endIndent: AppDimens.paddingMedium,
        );
      }
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDimens.spacerMedium,
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        AppDimens.spacerSmall,
        DetailsCard(
          isMargin: false,
          isPadding: false,
          child: ClipPath.shape(
            shape: const RoundedSuperellipseBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppDimens.borderRadiusLarge),
              ),
            ),
            child: Column(children: sectionChildren),
          ),
        ),
      ],
    );
  }
}

class SettingsOptionInsets extends InheritedWidget {
  const SettingsOptionInsets({
    super.key,
    required this.padding,
    required super.child,
  });

  final EdgeInsets padding;

  static EdgeInsets of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SettingsOptionInsets>()
          ?.padding ??
      EdgeInsets.zero;

  @override
  bool updateShouldNotify(SettingsOptionInsets oldWidget) =>
      padding != oldWidget.padding;
}
