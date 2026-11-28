import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NotificationHelper {
  static void showSuccessNotification(BuildContext context, String message) {
    _show(
      context,
      context.l10n.commonSuccess,
      message,
      ToastificationType.success,
    );
  }

  static void showFailureNotification(BuildContext context, String message) {
    _show(context, context.l10n.commonError, message, ToastificationType.error);
  }

  static void _show(
    BuildContext context,
    String title,
    String message,
    ToastificationType type,
  ) {
    final theme = Theme.of(context);
    final legacy = WalletCorners.of(context);
    const radius = BorderRadius.all(
      Radius.circular(AppDimens.borderRadiusLarge),
    );
    final border = BorderSide(color: theme.cardColor.withValues(alpha: 0.7));
    final shadows = [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.2),
        blurRadius: AppSizes.dp8,
        offset: const Offset(0, AppSizes.dp4),
      ),
    ];
    final shape = RoundedSuperellipseBorder(borderRadius: radius, side: border);

    toastification.show(
      context: context,
      type: type,
      backgroundColor: theme.cardColor,
      foregroundColor: theme.textTheme.bodyLarge!.color,
      borderRadius: legacy ? radius : BorderRadius.zero,
      borderSide: legacy ? border : BorderSide.none,
      boxShadow: legacy ? shadows : const [],
      margin: legacy ? null : EdgeInsets.zero,
      animationBuilder: legacy
          ? null
          : (
              context,
              animation,
              alignment,
              child,
            ) => DefaultToastificationTransition(
              animation: animation,
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  decoration: ShapeDecoration(shape: shape, shadows: shadows),
                  foregroundDecoration: ShapeDecoration(shape: shape),
                  child: ClipRSuperellipse(borderRadius: radius, child: child),
                ),
              ),
            ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.headlineSmall!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(message, style: theme.textTheme.bodySmall),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
