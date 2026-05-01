import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';

abstract class NotificationRepository {
  Future<void> initialize();
  Future<void> enableAuthenticatedNotifications();
  Stream<AppNotificationEntity> watchEvents();
}
