import 'package:flutter/material.dart';

import '../themes/app_dimens.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusExtraLarge)),
    ),
    constraints: BoxConstraints(
      minHeight: screenHeight * 0.95,
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


