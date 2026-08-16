import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/settings_profile_update_entity.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsProfileUpdatedRequested extends SettingsEvent {
  const SettingsProfileUpdatedRequested(this.update);

  final SettingsProfileUpdateEntity update;
}

class SettingsProAccessRequested extends SettingsEvent {
  const SettingsProAccessRequested(this.request);

  final ProUpgradeRequestEntity request;
}

class SettingsSignOutRequested extends SettingsEvent {
  const SettingsSignOutRequested();
}

class SettingsDeleteAccountRequested extends SettingsEvent {
  const SettingsDeleteAccountRequested(this.request);

  final DeleteAccountRequestEntity request;
}

/// Ends the session once the deletion confirmation sheet has closed.
class SettingsAccountDeletionFinalized extends SettingsEvent {
  const SettingsAccountDeletionFinalized();
}

class SettingsFeedbackConsumed extends SettingsEvent {
  const SettingsFeedbackConsumed();
}
