part of 'notification_bloc.dart';

class NotificationState {
  const NotificationState({
    required this.isInitialized,
    this.lastNotification,
    this.errorMessage,
  });

  final bool isInitialized;
  final AppNotificationEntity? lastNotification;
  final String? errorMessage;

  factory NotificationState.initial() {
    return const NotificationState(isInitialized: false);
  }

  NotificationState copyWith({
    bool? isInitialized,
    AppNotificationEntity? lastNotification,
    String? errorMessage,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      lastNotification: lastNotification ?? this.lastNotification,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
