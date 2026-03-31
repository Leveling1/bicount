import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';

import '../../../../subscription/data/models/subscription.model.dart';

abstract class NotificationLocalDataSource {
  Future<void> initialize(
    void Function(AppNotificationEntity notification) onTap,
  );
  Future<void> showForegroundNotification(AppNotificationEntity notification);
  Future<void> scheduleSubscriptionReminder(SubscriptionModel subscription);
  Future<void> cancelSubscriptionReminder(String subscriptionId);
}
