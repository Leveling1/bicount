import 'package:bicount/features/whats_new/domain/repositories/whats_new_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewRepositoryImpl implements WhatsNewRepository {
  const WhatsNewRepositoryImpl();

  // Use the current preferences API for this installation-wide setting.
  // Session sign-out clears the store used by the legacy preferences API.
  static const _keyPrefix = 'bicount.whats_new.dismissed.';

  @override
  Future<bool> wasDismissed(String releaseId) async =>
      await SharedPreferencesAsync().getBool('$_keyPrefix$releaseId') ?? false;

  @override
  Future<void> markDismissed(String releaseId) =>
      SharedPreferencesAsync().setBool('$_keyPrefix$releaseId', true);
}
