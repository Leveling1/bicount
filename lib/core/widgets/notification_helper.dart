import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NotificationHelper {
  static void showSuccessNotification(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text('Success'),
      description: Text(message),
      type: ToastificationType.success,
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void showFailureNotification(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text('Error'),
      description: Text(message),
      type: ToastificationType.error,
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
