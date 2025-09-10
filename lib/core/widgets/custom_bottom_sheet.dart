import 'package:flutter/material.dart';

import '../themes/app_dimens.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  required Color? color,
  required double minHeight,
}) {
  color ??= Theme.of(context).scaffoldBackgroundColor;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusExtraLarge)),
    ),
    constraints: BoxConstraints(
      minWidth: screenWidth,
      minHeight: screenHeight * minHeight,
      maxHeight: screenHeight * 0.95,
    ),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(child: child),
        ),
      );
    },
  );
}


