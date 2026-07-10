import 'dart:async';

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';
import 'package:bicount/features/notification/domain/repositories/notification_permission_repository.dart';
import 'package:bicount/features/notification/presentation/widgets/notification_permission_sheet.dart';
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

    final context = navigatorKey.currentContext;
    if (context == null || _isPromptVisible) {
      return false;
    }

    _isPromptVisible = true;
    bool? accepted;
    try {
      accepted = await _showPermissionSheet(context, action);
    } finally {
      _isPromptVisible = false;
    }

    if (accepted != true) {
      return false;
    }

    final granted = await repository.requestOsPermission();
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

    final context = navigatorKey.currentContext;
    if (context == null || _isPromptVisible) {
      return;
    }

    _isPromptVisible = true;
    bool? accepted;
    try {
      accepted = await _showDeviceChangeSheet(context);
    } finally {
      _isPromptVisible = false;
    }

    if (accepted != true) {
      return;
    }

    final granted = await repository.requestOsPermission();
    if (granted) {
      unawaited(repository.syncDeviceToken());
    }
  }

  Future<void> _ensureTokenSynced() async {
    if (await repository.hasFcmTokenChanged()) {
      await repository.syncDeviceToken();
    }
  }

  Future<bool?> _showPermissionSheet(
    BuildContext context,
    NotifiableAction action,
  ) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetContext) => NotificationPermissionSheet(
        title: l10n.notifPermissionTitle,
        reason: _reasonFor(l10n, action),
        enableLabel: l10n.notifPermissionEnable,
        skipLabel: l10n.notifPermissionSkip,
      ),
    );
  }

  Future<bool?> _showDeviceChangeSheet(BuildContext context) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetContext) => NotificationPermissionSheet(
        title: l10n.notifPermissionDeviceChangedTitle,
        reason: l10n.notifPermissionDeviceChangedBody,
        enableLabel: l10n.notifPermissionEnable,
        skipLabel: l10n.notifPermissionSkip,
      ),
    );
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
}
