import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferences {
  static const _key = 'bicount_locale_preference';

  Future<String?> readLocaleCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key);
  }

  Future<void> saveLocaleCode(String? localeCode) async {
    final preferences = await SharedPreferences.getInstance();
    if (localeCode == null || localeCode.isEmpty) {
      await preferences.remove(_key);
      return;
    }
    await preferences.setString(_key, localeCode);
  }
}
