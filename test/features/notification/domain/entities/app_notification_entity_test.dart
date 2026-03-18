import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification payload roundtrip preserves category and route', () {
    const notification = AppNotificationEntity(
      category: AppNotificationCategory.friendInvite,
      source: AppNotificationSource.foreground,
      title: 'New invite',
      body: 'Louis invited you',
      data: {'invite_code': 'abc123'},
      route: '/friend/invite?code=abc123',
    );

    final decoded = AppNotificationEntity.fromPayload(
      notification.encodePayload(),
      fallbackSource: AppNotificationSource.localTap,
    );

    expect(decoded.category, AppNotificationCategory.friendInvite);
    expect(decoded.source, AppNotificationSource.localTap);
    expect(decoded.route, '/friend/invite?code=abc123');
    expect(decoded.data['invite_code'], 'abc123');
  });
}
