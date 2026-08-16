import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/notification/presentation/services/notification_permission_service.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:flutter/material.dart';

/// Settings entry for notifications. Shows the current OS answer and leads to
/// the explainer screen, which then either raises the native dialog or sends
/// the user to the system settings depending on what is still possible.
///
/// Watches the app lifecycle because a change made in the system settings
/// never notifies the app: without re-reading on resume, someone could grant
/// the permission and the app would carry on believing it was refused —
/// and never register the device.
class SettingsNotificationsTile extends StatefulWidget {
  const SettingsNotificationsTile({super.key, required this.service});

  final NotificationPermissionService service;

  @override
  State<SettingsNotificationsTile> createState() =>
      _SettingsNotificationsTileState();
}

class _SettingsNotificationsTileState extends State<SettingsNotificationsTile>
    with WidgetsBindingObserver {
  bool? _isEnabled;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    // Back from the system settings, possibly with a different answer. This
    // is also what finally registers the device for someone who had refused
    // and just changed their mind.
    widget.service.refreshAfterReturningFromSystemSettings().then((enabled) {
      if (mounted) {
        setState(() => _isEnabled = enabled);
      }
    });
  }

  Future<void> _readState() async {
    final enabled = await widget.service.isEnabledOnDevice();
    if (mounted) {
      setState(() => _isEnabled = enabled);
    }
  }

  Future<void> _openFlow() async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      final enabled = await widget.service.manageFromSettings(context);
      if (mounted) {
        setState(() => _isEnabled = enabled);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _isEnabled;

    return SettingsActionTile(
      icon: enabled == true
          ? Icons.notifications_active_outlined
          : Icons.notifications_off_outlined,
      title: context.l10n.settingsNotificationsTitle,
      subtitle: switch (enabled) {
        null => context.l10n.settingsNotificationsChecking,
        true => context.l10n.settingsNotificationsEnabled,
        false => context.l10n.settingsNotificationsDisabled,
      },
      isLoading: _isBusy,
      onTap: _openFlow,
    );
  }
}
