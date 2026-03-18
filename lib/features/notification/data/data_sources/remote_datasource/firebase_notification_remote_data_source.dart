import 'package:app_links/app_links.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/notification_remote_datasource.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  FirebaseNotificationRemoteDataSource({
    required this.messaging,
    required this.supabase,
    required this.appLinks,
  });

  final FirebaseMessaging messaging;
  final SupabaseClient supabase;
  final AppLinks appLinks;

  @override
  Stream<AppNotificationEntity> deepLinks() {
    return appLinks.uriLinkStream.map(_mapUriToNotification);
  }

  @override
  Stream<AppNotificationEntity> foregroundMessages() {
    return FirebaseMessaging.onMessage.map(
      (message) => _mapRemoteMessage(message, AppNotificationSource.foreground),
    );
  }

  @override
  Future<AppNotificationEntity?> getInitialEvent() async {
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      return _mapRemoteMessage(initialMessage, AppNotificationSource.openedApp);
    }

    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      return _mapUriToNotification(initialLink);
    }

    return null;
  }

  @override
  Stream<AppNotificationEntity> openedMessages() {
    return FirebaseMessaging.onMessageOpenedApp.map(
      (message) => _mapRemoteMessage(message, AppNotificationSource.openedApp),
    );
  }

  @override
  Future<void> requestPermission() async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  @override
  Future<void> syncDeviceToken() async {
    final token = await messaging.getToken();
    final userId = supabase.auth.currentUser?.id;

    if (token == null || userId == null) {
      return;
    }

    try {
      await supabase.from('device_tokens').upsert({
        'user_uid': userId,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // The handoff document describes the required Supabase table.
    }

    messaging.onTokenRefresh.listen((freshToken) async {
      try {
        await supabase.from('device_tokens').upsert({
          'user_uid': userId,
          'token': freshToken,
          'platform': defaultTargetPlatform.name,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}
    });
  }

  AppNotificationEntity _mapRemoteMessage(
    RemoteMessage message,
    AppNotificationSource source,
  ) {
    final data = message.data.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final category = AppNotificationCategoryX.fromValue(data['category']);
    final route =
        data['route'] ??
        (category == AppNotificationCategory.friendInvite &&
                data['invite_code'] != null
            ? '/friend/invite?code=${data['invite_code']}'
            : null);

    return AppNotificationEntity(
      category: category,
      source: source,
      title: message.notification?.title ?? data['title'] ?? 'Bicount',
      body: message.notification?.body ?? data['body'] ?? '',
      data: data,
      route: route,
    );
  }

  AppNotificationEntity _mapUriToNotification(Uri uri) {
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return AppNotificationEntity(
      category: AppNotificationCategory.deepLink,
      source: AppNotificationSource.deepLink,
      title: 'Open link',
      body: uri.toString(),
      data: uri.queryParameters.map((key, value) => MapEntry(key, value)),
      route: '${uri.path}$query',
    );
  }
}
