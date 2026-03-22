import 'dart:async';

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
  StreamSubscription<String>? _tokenRefreshSubscription;

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

    await _persistDeviceToken(userId, token);

    _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen((
      freshToken,
    ) async {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return;
      }

      await _persistDeviceToken(currentUserId, freshToken);
    });
  }

  Future<void> _persistDeviceToken(String userId, String token) async {
    final payload = {
      'user_uid': userId,
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final existingRows = List<Map<String, dynamic>>.from(
        await supabase
            .from('device_tokens')
            .select('token_id')
            .eq('user_uid', userId),
      );

      if (existingRows.isNotEmpty) {
        final primaryTokenId = existingRows.first['token_id'] as String?;

        if (primaryTokenId != null && primaryTokenId.isNotEmpty) {
          await supabase
              .from('device_tokens')
              .update(payload)
              .eq('token_id', primaryTokenId);

          await supabase
              .from('device_tokens')
              .delete()
              .eq('user_uid', userId)
              .neq('token_id', primaryTokenId);
          return;
        }

        await supabase
            .from('device_tokens')
            .update(payload)
            .eq('user_uid', userId);
        return;
      }

      await supabase.from('device_tokens').insert(payload);
    } catch (_) {
      // The handoff document describes the required Supabase table.
    }
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
      title: 'Bicount',
      body: uri.toString(),
      data: uri.queryParameters.map((key, value) => MapEntry(key, value)),
      route: '${uri.path}$query',
    );
  }
}
