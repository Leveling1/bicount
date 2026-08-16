import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bicount/core/constants/app_config.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/notification_remote_datasource.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Current messaging token, or null while it cannot be obtained yet. On Apple
/// platforms `getToken()` throws until the device is registered with APNs —
/// a "not yet" answer that must not surface as a failure, nor be mistaken for
/// "no token exists".
Future<String?> readDeviceToken(FirebaseMessaging messaging) async {
  try {
    return await messaging.getToken();
  } catch (_) {
    return null;
  }
}

class FirebaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  static const _allUsersTopic = 'all_users';

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
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _syncAllUsersTopicMembership(settings);
  }

  @override
  Future<void> syncDeviceToken() async {
    await _syncAllUsersTopicMembership(
      await messaging.getNotificationSettings(),
    );

    // Subscribed before the first read, and never behind an early return.
    // On iOS the token does not exist until APNs registration completes, and
    // it then arrives only through this stream. Wiring it afterwards meant a
    // device that came up empty was never registered at all — which is why
    // iOS devices stopped receiving anything.
    _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen((
      freshToken,
    ) async {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return;
      }

      await _persistDeviceToken(currentUserId, freshToken);
    });

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    // Null simply means "not ready yet"; the stream above takes over.
    final token = await readDeviceToken(messaging);
    if (token == null) {
      return;
    }

    await _persistDeviceToken(userId, token);
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
            .from('fcm_tokens')
            .select('token_id')
            .eq('user_uid', userId),
      );

      if (existingRows.isNotEmpty) {
        final primaryTokenId = existingRows.first['token_id'] as String?;

        if (primaryTokenId != null && primaryTokenId.isNotEmpty) {
          await supabase
              .from('fcm_tokens')
              .update(payload)
              .eq('token_id', primaryTokenId);

          await supabase
              .from('fcm_tokens')
              .delete()
              .eq('user_uid', userId)
              .neq('token_id', primaryTokenId);
          return;
        }

        await supabase
            .from('fcm_tokens')
            .update(payload)
            .eq('user_uid', userId);
        return;
      }

      await supabase.from('fcm_tokens').insert(payload);
    } catch (_) {
      // The handoff document describes the required Supabase table.
    }
  }

  Future<void> _syncAllUsersTopicMembership(
    NotificationSettings settings,
  ) async {
    final authorizationStatus = settings.authorizationStatus;
    final isAuthorized =
        authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;

    try {
      if (isAuthorized) {
        await messaging.subscribeToTopic(_allUsersTopic);
      } else {
        await messaging.unsubscribeFromTopic(_allUsersTopic);
      }
    } catch (_) {
      // Topic subscription is a convenience layer. Push token sync remains
      // the primary notification addressing path when topic management fails.
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
            ? '/friend/invite?${AppConfig.inviteCodeQueryParam}=${data['invite_code']}'
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
    final route = _resolveRouteFromUri(uri);
    return AppNotificationEntity(
      category: AppNotificationCategory.deepLink,
      source: AppNotificationSource.deepLink,
      title: 'Bicount',
      body: uri.toString(),
      data: uri.queryParameters.map((key, value) => MapEntry(key, value)),
      route: route,
    );
  }

  String _resolveRouteFromUri(Uri uri) {
    final query = uri.hasQuery ? '?${uri.query}' : '';
    if (uri.scheme == AppConfig.appScheme) {
      final basePath = uri.host.isEmpty ? uri.path : '/${uri.host}${uri.path}';
      return '$basePath$query';
    }
    return '${uri.path}$query';
  }
}
