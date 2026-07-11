import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({super.key, required this.text, required this.color, this.height = 24, this.fontSize = 11});
  final String text;
  final Color color;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 15, bottom: 15),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
