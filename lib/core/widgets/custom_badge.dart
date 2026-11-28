import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.text,
    required this.color,
    this.height = AppSizes.dp24,
    this.fontSize = AppSizes.dp11,
  });
  final String text;
  final Color color;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingMedium,
        top: AppSizes.dp15,
        bottom: AppSizes.dp15,
      ),
      child: Container(
        height: height,
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.3),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingExtraSmall,
          vertical: AppDimens.paddingExtraSmall,
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
