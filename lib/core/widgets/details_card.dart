import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:flutter/material.dart';

import '../themes/app_dimens.dart';

class DetailsCard extends StatelessWidget {
  final Widget child;
  final bool isMargin;
  final bool isPadding;
  final VoidCallback? onTap;
  const DetailsCard({
    super.key,
    required this.child,
    this.isMargin = true,
    this.isPadding = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppDimens.borderRadiusLarge),
      ),
    );
    final color = Theme.of(context).cardColor;
    final content = isPadding
        ? Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: child,
          )
        : child;
    return Container(
      width: double.infinity,
      margin: isMargin
          ? const EdgeInsets.only(top: AppDimens.marginMedium)
          : null,
      child: onTap == null
          ? DecoratedBox(
              decoration: ShapeDecoration(color: color, shape: shape),
              child: content,
            )
          : BicountPressable(
              onTap: onTap,
              color: color,
              customBorder: shape,
              child: content,
            ),
    );
  }
}
