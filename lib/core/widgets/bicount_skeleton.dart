import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class BicountSkeletonBox extends StatelessWidget {
  const BicountSkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppDimens.borderRadiusMedium,
    this.margin,
    this.preserveWalletCorners = false,
  });

  final double width;
  final double height;
  final double radius;
  final bool preserveWalletCorners;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).cardColor.withValues(alpha: 0.55);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: ShapeDecoration(
        color: color,
        shape: appCornerShape(
          borderRadius: BorderRadius.circular(radius),
          legacy: preserveWalletCorners,
        ),
      ),
    );
  }
}

class BicountSkeletonCircle extends StatelessWidget {
  const BicountSkeletonCircle({super.key, required this.size, this.margin});

  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).cardColor.withValues(alpha: 0.55);

    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
