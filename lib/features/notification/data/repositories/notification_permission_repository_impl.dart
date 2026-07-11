import 'package:bicount/features/notification/data/data_sources/local_datasource/notification_permission_local_data_source.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/notification_remote_datasource.dart';
import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';
import 'package:bicount/features/notification/domain/repositories/notification_permission_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPermissionRepositoryImpl
    implements NotificationPermissionRepository {
  NotificationPermissionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.messaging,
    required this.plugin,
  });

  final NotificationPermissionLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteDataSource;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin plugin;

  @override
  Future<bool> isActionGranted(NotifiableAction action) {
    return localDataSource.isActionGranted(action);
  }

  @override
  Future<Set<NotifiableAction>> getGrantedActions() {
    return localDataSource.getGrantedActions();
  }

  @override
  Future<void> markActionGranted(NotifiableAction action) {
    return localDataSource.markActionGranted(action);
  }

  @override
  Future<bool> requestOsPermission() async {
    // Use the result directly from requestPermission() rather than a
    // separate getNotificationSettings() call — on iOS the latter can
    // return stale data immediately after the native dialog is dismissed.
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+ needs a runtime POST_NOTIFICATIONS grant for local
    // notifications (scheduled reminders, foreground alerts).
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    return _isAuthorized(settings.authorizationStatus);
  }

  @override
  Future<bool> isOsPermissionAuthorized() async {
    final settings = await messaging.getNotificationSettings();
    return _isAuthorized(settings.authorizationStatus);
  }

  @override
  Future<void> syncDeviceToken() async {
    await remoteDataSource.syncDeviceToken();
    final token = await messaging.getToken();
    if (token != null) {
      await localDataSource.saveFcmToken(token);
    }
  }

  @override
  Future<bool> hasFcmTokenChanged() async {
    final currentToken = await messaging.getToken();
    if (currentToken == null) {
      return false;
    }
    final lastToken = await localDataSource.getLastFcmToken();
    return lastToken == null || lastToken != currentToken;
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }
}
