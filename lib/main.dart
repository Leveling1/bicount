import 'package:bicount/app/bicount_app.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function required by Firebase — runs in a separate Dart isolate
// when the app is in background or fully terminated on Android, and in the
// main isolate on iOS (but iOS cannot show local notifications from here).
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // If the FCM message already carries a notification payload (title/body),
  // Android and iOS display it automatically via the OS — nothing to do.
  if (message.notification != null) return;

  // For data-only FCM messages on Android, build a local notification manually.
  // On iOS, the server must include a notification field for terminated-state
  // display; flutter_local_notifications cannot show UI from a background isolate.
  final title = message.data['title'] as String?;
  final body = message.data['body'] as String?;
  if (title == null && body == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
    ),
  );

  await plugin.show(
    message.hashCode & 0x7fffffff,
    title ?? 'Bicount',
    body ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'bicount_background',
        'Bicount',
        channelDescription: 'Bicount notifications',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF132318),
      ),
    ),
  );
}

Future<void> main() async {
  await bootstrapBicountApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await BicountHomeWidgetService.instance.initialize();
  runApp(const MyApp());
}
