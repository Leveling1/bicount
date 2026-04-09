part of 'notification_bloc.dart';

sealed class NotificationEvent {
  const NotificationEvent();
}

final class NotificationBootstrapRequested extends NotificationEvent {
  const NotificationBootstrapRequested();
}

final class _NotificationEventReceived extends NotificationEvent {
  const _NotificationEventReceived(this.notification);

  final AppNotificationEntity notification;
}

final class _NotificationFailed extends NotificationEvent {
  const _NotificationFailed(this.message);

  final String message;
}
