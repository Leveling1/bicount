import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_dimens.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Color? color,
  required double minHeight, // kept for compatibility, not used
}) {
  final bgColor = color ?? Theme.of(context).scaffoldBackgroundColor;
  final media = MediaQuery.of(context);
  final screenHeight = media.size.height;
  final screenWidth = media.size.width;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: bgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusExtraLarge)),
    ),
    constraints: BoxConstraints(
      minWidth: screenWidth,
      maxHeight: screenHeight * 0.95,
    ),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 15,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final handleHeight = 5.h;
              const spacing = 25.0;
              final scrollMaxHeight = (constraints.maxHeight - handleHeight - spacing).clamp(0.0, double.infinity);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50.w,
                    height: handleHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
                    ),
                  ),
                  const SizedBox(height: spacing),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: scrollMaxHeight),
                    child: SingleChildScrollView(child: child),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}


