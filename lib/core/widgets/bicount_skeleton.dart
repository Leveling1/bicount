import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class BicountSkeletonBox extends StatelessWidget {
  const BicountSkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppDimens.borderRadiusMedium,
    this.margin,
  });

  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).cardColor.withValues(alpha: 0.55);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
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
