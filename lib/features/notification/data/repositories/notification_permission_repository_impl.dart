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
    // Delegate the FCM-side request to the remote data source so the
    // `all_users` topic membership stays in sync.
    await remoteDataSource.requestPermission();

    // Ensure the local notifications plugin also has the OS permission
    // needed to display scheduled reminders (Android 13+ POST_NOTIFICATIONS
    // and iOS notification authorization).
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

    final settings = await messaging.getNotificationSettings();
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
