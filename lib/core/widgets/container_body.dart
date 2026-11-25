import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class ContainerBody extends StatelessWidget {
  const ContainerBody({
    super.key,
    required this.child,
    this.protectTopInset = true,
    this.preserveWalletCorners = false,
  });

  final Widget child;
  final bool protectTopInset;
  final bool preserveWalletCorners;

  static const _radius = BorderRadius.only(
    bottomLeft: Radius.circular(AppDimens.borderRadiusUltraLarge),
    bottomRight: Radius.circular(AppDimens.borderRadiusUltraLarge),
  );

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;
    return SafeArea(
      top: protectTopInset,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.marginExtraSmall),
        decoration: preserveWalletCorners
            ? BoxDecoration(color: color, borderRadius: _radius)
            : ShapeDecoration(
                color: color,
                shape: const RoundedSuperellipseBorder(borderRadius: _radius),
              ),
        child: preserveWalletCorners
            ? ClipRRect(borderRadius: _radius, child: child)
            : ClipRSuperellipse(borderRadius: _radius, child: child),
      ),
    );
  }
}
