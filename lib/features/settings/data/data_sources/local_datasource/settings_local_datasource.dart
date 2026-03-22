import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/settings/domain/entities/settings_profile_update_entity.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:brick_core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingsLocalDataSource {
  Future<AppThemePreference> readThemePreference();
  Future<void> saveThemePreference(AppThemePreference preference);
  Future<void> updateProfile(SettingsProfileUpdateEntity update);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _themePreferenceKey = 'bicount_theme_preference';

  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<AppThemePreference> readThemePreference() async {
    final preferences = await SharedPreferences.getInstance();
    switch (preferences.getString(_themePreferenceKey)) {
      case 'light':
        return AppThemePreference.light;
      case 'dark':
        return AppThemePreference.dark;
      default:
        return AppThemePreference.system;
    }
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    final preferences = await SharedPreferences.getInstance();
    switch (preference) {
      case AppThemePreference.system:
        await preferences.remove(_themePreferenceKey);
        return;
      case AppThemePreference.light:
        await preferences.setString(_themePreferenceKey, 'light');
        return;
      case AppThemePreference.dark:
        await preferences.setString(_themePreferenceKey, 'dark');
        return;
    }
  }

  @override
  Future<void> updateProfile(SettingsProfileUpdateEntity update) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw MessageFailure(message: 'Authentication failure');
    }

    try {
      final currentUsers = await Repository().get<UserModel>(
        query: Query(where: [Where.exact('uid', uid)]),
      );
      if (currentUsers.isEmpty) {
        throw MessageFailure(message: 'Unable to save your profile right now.');
      }
      final currentUser = currentUsers.first;

      await Repository().upsert<UserModel>(
        UserModel(
          sid: currentUser.sid,
          uid: currentUser.uid,
          image: update.image,
          username: update.username,
          email: currentUser.email,
          incomes: currentUser.incomes,
          expenses: currentUser.expenses,
          balance: currentUser.balance,
          companyIncome: currentUser.companyIncome,
          personalIncome: currentUser.personalIncome,
        ),
      );
    } catch (_) {
      throw MessageFailure(message: 'Unable to save your profile right now.');
    }
  }
}
