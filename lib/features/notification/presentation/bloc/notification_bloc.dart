import 'dart:async';

import 'package:bicount/core/constants/app_config.dart';
import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/core/routes/friend_invite_route.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:bicount/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this.repository) : super(NotificationState.initial()) {
    on<NotificationBootstrapRequested>(_onNotificationBootstrapRequested);
    on<_NotificationAuthSessionChanged>(_onNotificationAuthSessionChanged);
    on<_NotificationEventReceived>(_onNotificationEventReceived);
    on<_NotificationFailed>(_onNotificationFailed);
  }

  final NotificationRepository repository;
  StreamSubscription<AppNotificationEntity>? _eventsSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  AppNotificationEntity? _pendingNavigation;
  String? _activeAuthenticatedUserId;
  bool _navigationRetryScheduled = false;

  Future<void> _onNotificationBootstrapRequested(
    NotificationBootstrapRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _eventsSubscription ??= repository.watchEvents().listen(
        (notification) => add(_NotificationEventReceived(notification)),
        onError: (error, _) => add(_NotificationFailed(error.toString())),
      );
      _authSubscription ??= Supabase.instance.client.auth.onAuthStateChange
          .listen(
            (authState) => add(
              _NotificationAuthSessionChanged(authState.session?.user.id),
            ),
            onError: (error, _) => add(_NotificationFailed(error.toString())),
          );
      await repository.initialize();
      add(
        _NotificationAuthSessionChanged(
          Supabase.instance.client.auth.currentUser?.id,
        ),
      );
      emit(state.copyWith(isInitialized: true));
    } catch (error) {
      add(_NotificationFailed(error.toString()));
    }
  }

  Future<void> _onNotificationAuthSessionChanged(
    _NotificationAuthSessionChanged event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = event.userId;
    if (userId == _activeAuthenticatedUserId) {
      return;
    }

    _activeAuthenticatedUserId = userId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      await repository.enableAuthenticatedNotifications();
    } catch (error) {
      add(_NotificationFailed(error.toString()));
    }
  }

  void _onNotificationEventReceived(
    _NotificationEventReceived event,
    Emitter<NotificationState> emit,
  ) {
    final notification = event.notification;

    // Deep links are routed by go_router + MainScreen.
    // Only navigate here for notification taps (opened, localTap).
    final shouldNavigate =
        notification.source != AppNotificationSource.foreground &&
        notification.source != AppNotificationSource.deepLink &&
        notification.route != null &&
        notification.route!.isNotEmpty;

    if (shouldNavigate) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        _pendingNavigation = null;
        final routeUri = Uri.tryParse(notification.route!);
        if (routeUri != null && FriendInviteRoute.isInvitePath(routeUri)) {
          _navigateToInviteRoute(context, routeUri);
        } else {
          context.go(notification.route!);
        }
      } else {
        _pendingNavigation = notification;
        _scheduleNavigationRetry();
      }
    }

    emit(state.copyWith(lastNotification: notification));
  }

  void _scheduleNavigationRetry() {
    if (_navigationRetryScheduled) {
      return;
    }

    _navigationRetryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationRetryScheduled = false;
      final pendingNavigation = _pendingNavigation;
      if (pendingNavigation == null || isClosed) {
        return;
      }
      add(_NotificationEventReceived(pendingNavigation));
    });
  }

  void _navigateToInviteRoute(BuildContext context, Uri routeUri) {
    final inviteCode = FriendInviteRoute.inviteCodeFromUri(routeUri);
    if (inviteCode == null || inviteCode.isEmpty) {
      context.go(AppConfig.invitePath);
      return;
    }

    final currentUri = GoRouter.of(context).state.uri;

    // Only skip if the embedded invite page is already showing this code.
    if (FriendInviteRoute.isInvitePath(currentUri) &&
        FriendInviteRoute.isEmbedded(currentUri) &&
        FriendInviteRoute.matches(currentUri, inviteCode)) {
      return;
    }

    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    if (!isLoggedIn) {
      context.go(FriendInviteRoute.buildAuthRoute(inviteCode: inviteCode));
      return;
    }

    // Defer to next frame so go_router finishes its own platform-initiated
    // deep-link redirect before we push the secondary invite page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = rootNavigatorKey.currentContext;
      if (nav == null) {
        return;
      }
      final activeUri = GoRouter.of(nav).state.uri;
      if (FriendInviteRoute.isInvitePath(activeUri) &&
          FriendInviteRoute.isEmbedded(activeUri) &&
          FriendInviteRoute.matches(activeUri, inviteCode)) {
        return;
      }
      nav.push(FriendInviteRoute.buildSecondaryRoute(inviteCode));
    });
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
    await _authSubscription?.cancel();
    return super.close();
  }
}
