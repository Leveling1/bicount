import 'package:bicount/features/notification/data/data_sources/local_datasource/notification_permission_local_data_source.dart';
import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionLocalDataSourceImpl
    implements NotificationPermissionLocalDataSource {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<bool> isActionGranted(NotifiableAction action) async {
    final prefs = await _prefs;
    return prefs.containsKey(action.storageKey);
  }

  @override
  Future<Set<NotifiableAction>> getGrantedActions() async {
    final prefs = await _prefs;
    return NotifiableAction.values
        .where((action) => prefs.containsKey(action.storageKey))
        .toSet();
  }

  @override
  Future<void> markActionGranted(NotifiableAction action) async {
    final prefs = await _prefs;
    await prefs.setString(
      action.storageKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<String?> getLastFcmToken() async {
    final prefs = await _prefs;
    return prefs.getString(NotifiableActionX.fcmTokenStorageKey);
  }

  @override
  Future<void> saveFcmToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(NotifiableActionX.fcmTokenStorageKey, token);
  }
}
