import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';

import '../../../subscription/data/models/subscription.model.dart';

abstract class NotificationRepository {
  Future<void> initialize();
  Stream<AppNotificationEntity> watchEvents();
  Future<void> syncSubscriptions(List<SubscriptionModel> subscriptions);
}
