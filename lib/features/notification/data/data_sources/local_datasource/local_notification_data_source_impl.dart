import 'package:bicount/features/notification/data/data_sources/local_datasource/notification_local_datasource.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../subscription/data/models/subscription.model.dart';

class LocalNotificationDataSourceImpl implements NotificationLocalDataSource {
  LocalNotificationDataSourceImpl(this.plugin);

  final FlutterLocalNotificationsPlugin plugin;

  @override
  Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    await plugin.cancel(_subscriptionNotificationId(subscriptionId));
  }

  @override
  Future<void> initialize(
    void Function(AppNotificationEntity notification) onTap,
  ) async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        onTap(
          AppNotificationEntity.fromPayload(
            payload,
            fallbackSource: AppNotificationSource.localTap,
          ),
        );
      },
    );
  }

  @override
  Future<void> requestPermission() async {
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> scheduleSubscriptionReminder(
    SubscriptionModel subscription,
  ) async {
    final nextBillingDate = DateTime.tryParse(
      subscription.nextBillingDate,
    )?.toLocal();
    if (nextBillingDate == null) {
      return;
    }

    final scheduledDate = DateTime(
      nextBillingDate.year,
      nextBillingDate.month,
      nextBillingDate.day,
      9,
    );

    if (!scheduledDate.isAfter(DateTime.now())) {
      return;
    }

    final notification = AppNotificationEntity(
      category: AppNotificationCategory.subscriptionDue,
      source: AppNotificationSource.localTap,
      title: subscription.title,
      body:
          'Your subscription of ${subscription.amount.toStringAsFixed(2)} ${subscription.currency} is due today.',
      data: {
        'subscription_id': subscription.subscriptionId ?? subscription.sid,
      },
      route: '/analysis',
    );

    await plugin.zonedSchedule(
      _subscriptionNotificationId(
        subscription.subscriptionId ?? subscription.sid,
      ),
      notification.title,
      notification.body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription reminders',
          channelDescription: 'Reminders for upcoming subscription charges',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notification.encodePayload(),
    );
  }

  @override
  Future<void> showForegroundNotification(
    AppNotificationEntity notification,
  ) async {
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bicount_foreground',
          'Bicount live events',
          channelDescription: 'Foreground alerts for Bicount activity',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: notification.encodePayload(),
    );
  }

  int _subscriptionNotificationId(String subscriptionId) {
    return subscriptionId.hashCode & 0x7fffffff;
  }
}
