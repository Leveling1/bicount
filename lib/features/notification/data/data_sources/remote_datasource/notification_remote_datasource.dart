import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<void> requestPermission();
  Future<void> syncDeviceToken();
  Stream<AppNotificationEntity> foregroundMessages();
  Stream<AppNotificationEntity> openedMessages();
  Stream<AppNotificationEntity> deepLinks();
  Future<AppNotificationEntity?> getInitialEvent();
}
