import 'dart:convert';

import 'package:equatable/equatable.dart';

enum AppNotificationCategory {
  friendInvite,
  friendAccept,
  transactionCreated,
  subscriptionDue,
  subscriptionChanged,
  deepLink,
  unknown,
}

extension AppNotificationCategoryX on AppNotificationCategory {
  String get value {
    switch (this) {
      case AppNotificationCategory.friendInvite:
        return 'friend_invite';
      case AppNotificationCategory.friendAccept:
        return 'friend_accept';
      case AppNotificationCategory.transactionCreated:
        return 'transaction_created';
      case AppNotificationCategory.subscriptionDue:
        return 'subscription_due';
      case AppNotificationCategory.subscriptionChanged:
        return 'subscription_changed';
      case AppNotificationCategory.deepLink:
        return 'deep_link';
      case AppNotificationCategory.unknown:
        return 'unknown';
    }
  }

  static AppNotificationCategory fromValue(String? value) {
    switch (value) {
      case 'friend_invite':
        return AppNotificationCategory.friendInvite;
      case 'friend_accept':
        return AppNotificationCategory.friendAccept;
      case 'transaction_created':
        return AppNotificationCategory.transactionCreated;
      case 'subscription_due':
        return AppNotificationCategory.subscriptionDue;
      case 'subscription_changed':
        return AppNotificationCategory.subscriptionChanged;
      case 'deep_link':
        return AppNotificationCategory.deepLink;
      default:
        return AppNotificationCategory.unknown;
    }
  }
}

enum AppNotificationSource { foreground, openedApp, localTap, deepLink }

class AppNotificationEntity extends Equatable {
  const AppNotificationEntity({
    required this.category,
    required this.source,
    required this.title,
    required this.body,
    required this.data,
    this.route,
  });

  final AppNotificationCategory category;
  final AppNotificationSource source;
  final String title;
  final String body;
  final Map<String, String> data;
  final String? route;

  String encodePayload() {
    return jsonEncode({
      'category': category.value,
      'source': source.name,
      'title': title,
      'body': body,
      'route': route,
      'data': data,
    });
  }

  factory AppNotificationEntity.fromPayload(
    String payload, {
    required AppNotificationSource fallbackSource,
  }) {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return AppNotificationEntity(
      category: AppNotificationCategoryX.fromValue(map['category'] as String?),
      source: fallbackSource,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      route: map['route'] as String?,
      data: (map['data'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  @override
  List<Object?> get props => [category, source, title, body, data, route];
}
