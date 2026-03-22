import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/settings_profile_update_entity.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';

abstract class SettingsRepository {
  Future<AppThemePreference> readThemePreference();
  Future<void> saveThemePreference(AppThemePreference preference);
  Future<void> updateProfile(SettingsProfileUpdateEntity update);
  Future<void> requestProAccess(ProUpgradeRequestEntity request);
  Future<void> signOut();
  Future<void> deleteAccount(DeleteAccountRequestEntity request);
}
