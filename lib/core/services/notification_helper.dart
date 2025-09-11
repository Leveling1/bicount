import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NotificationHelper {
  static void showSuccessNotification(BuildContext context, String message) {
    toastification.show(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      title: Text(
        'Success',
        style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      type: ToastificationType.success,
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void showFailureNotification(BuildContext context, String message) {
    toastification.show(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      title: Text(
        'Error',
        style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      type: ToastificationType.error,
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
