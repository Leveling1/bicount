import 'dart:async';

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';
import 'package:bicount/features/notification/domain/repositories/notification_permission_repository.dart';
import 'package:bicount/features/notification/presentation/screens/notification_permission_screen.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationPermissionService {
  NotificationPermissionService({
    required this.repository,
    required this.navigatorKey,
  });

  final NotificationPermissionRepository repository;
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isPromptVisible = false;

  Future<bool> requestForAction(NotifiableAction action) async {
    if (await repository.isActionGranted(action)) {
      unawaited(_ensureTokenSynced());
      return true;
    }

    // Once the OS has recorded an explicit denial, the native dialog can
    // never be shown again (this is permanent on iOS) — showing our own
    // "Enable notifications" screen at that point would just be a dead end
    // for the user on every future debt/salary entry, so stop asking.
    if (await repository.isOsPermissionPermanentlyDenied()) {
      return false;
    }

    final context = navigatorKey.currentContext;
    if (context == null || _isPromptVisible) {
      return false;
    }

    _isPromptVisible = true;
    bool granted = false;
    try {
      // The screen itself triggers the OS request and only pops once the
      // user has answered the native dialog, so by the time this resolves
      // `granted` is already the final decision — no separate
      // requestOsPermission() call needed here.
      granted = await _showPermissionScreen(context, action) ?? false;
    } finally {
      _isPromptVisible = false;
    }

    if (granted) {
      await repository.markActionGranted(action);
      unawaited(repository.syncDeviceToken());
    }
    return granted;
  }

  Future<void> checkDeviceState() async {
    final grantedActions = await repository.getGrantedActions();
    if (grantedActions.isEmpty) {
      return;
    }

    final osAuthorized = await repository.isOsPermissionAuthorized();
    if (osAuthorized) {
      if (await repository.hasFcmTokenChanged()) {
        await repository.syncDeviceToken();
      }
      return;
    }

    // Same reasoning as in requestForAction: once this device's OS
    // permission is explicitly denied, re-showing the prompt can never
    // succeed, so don't ask again.
    if (await repository.isOsPermissionPermanentlyDenied()) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null || _isPromptVisible) {
      return;
    }

    _isPromptVisible = true;
    bool granted = false;
    try {
      granted = await _showDeviceChangeScreen(context) ?? false;
    } finally {
      _isPromptVisible = false;
    }

    if (granted) {
      unawaited(repository.syncDeviceToken());
    }
  }

  Future<void> _ensureTokenSynced() async {
    if (await repository.hasFcmTokenChanged()) {
      await repository.syncDeviceToken();
    }
  }

  Future<bool?> _showPermissionScreen(
    BuildContext context,
    NotifiableAction action,
  ) {
    final l10n = context.l10n;
    return Navigator.of(context).push<bool>(
      _buildPermissionRoute(
        NotificationPermissionScreen(
          icon: _iconFor(action),
          title: l10n.notifPermissionTitle,
          primaryReason: _reasonFor(l10n, action),
          otherReasonsTitle: l10n.notifPermissionOtherReasonsTitle,
          otherReasons: _otherReasonsFor(l10n, action),
          enableLabel: l10n.notifPermissionEnable,
          skipLabel: l10n.notifPermissionSkip,
          onEnablePressed: repository.requestOsPermission,
        ),
      ),
    );
  }

  Future<bool?> _showDeviceChangeScreen(BuildContext context) {
    final l10n = context.l10n;
    return Navigator.of(context).push<bool>(
      _buildPermissionRoute(
        NotificationPermissionScreen(
          icon: Icons.phonelink_setup_outlined,
          title: l10n.notifPermissionDeviceChangedTitle,
          primaryReason: l10n.notifPermissionDeviceChangedBody,
          enableLabel: l10n.notifPermissionEnable,
          skipLabel: l10n.notifPermissionSkip,
          onEnablePressed: repository.requestOsPermission,
        ),
      ),
    );
  }

  PageRoute<bool> _buildPermissionRoute(Widget child) {
    return PageRouteBuilder<bool>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  IconData _iconFor(NotifiableAction action) {
    switch (action) {
      case NotifiableAction.debtRecorded:
        return Icons.receipt_long_outlined;
      case NotifiableAction.accountLinked:
        return Icons.link_outlined;
      case NotifiableAction.salaryRecorded:
        return Icons.payments_outlined;
    }
  }

  String _reasonFor(AppLocalizations l10n, NotifiableAction action) {
    switch (action) {
      case NotifiableAction.debtRecorded:
        return l10n.notifPermissionReasonDebtRecorded;
      case NotifiableAction.accountLinked:
        return l10n.notifPermissionReasonAccountLinked;
      case NotifiableAction.salaryRecorded:
        return l10n.notifPermissionReasonSalaryRecorded;
    }
  }

  List<String> _otherReasonsFor(AppLocalizations l10n, NotifiableAction action) {
    return NotifiableAction.values
        .where((value) => value != action)
        .map((value) => _reasonFor(l10n, value))
        .toList(growable: false);
  }
}
