import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            top: 15,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
                ),
              ),
              const SizedBox(height: 25),
              Expanded(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      );
    },
  );
}


