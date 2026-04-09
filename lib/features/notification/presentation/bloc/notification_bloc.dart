import 'dart:async';

import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:bicount/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this.repository) : super(NotificationState.initial()) {
    on<NotificationBootstrapRequested>(_onNotificationBootstrapRequested);
    on<_NotificationEventReceived>(_onNotificationEventReceived);
    on<_NotificationFailed>(_onNotificationFailed);
  }

  final NotificationRepository repository;
  StreamSubscription<AppNotificationEntity>? _eventsSubscription;

  Future<void> _onNotificationBootstrapRequested(
    NotificationBootstrapRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.initialize();
      _eventsSubscription ??= repository.watchEvents().listen(
        (notification) => add(_NotificationEventReceived(notification)),
        onError: (error, _) => add(_NotificationFailed(error.toString())),
      );
      emit(state.copyWith(isInitialized: true));
    } catch (error) {
      add(_NotificationFailed(error.toString()));
    }
  }

  void _onNotificationEventReceived(
    _NotificationEventReceived event,
    Emitter<NotificationState> emit,
  ) {
    final context = rootNavigatorKey.currentContext;

    if (context != null &&
        event.notification.source != AppNotificationSource.foreground &&
        event.notification.route != null &&
        event.notification.route!.isNotEmpty) {
      context.go(event.notification.route!);
    }

    emit(state.copyWith(lastNotification: event.notification));
  }

  void _onNotificationFailed(
    _NotificationFailed event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(errorMessage: event.message));
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    return super.close();
  }
}
