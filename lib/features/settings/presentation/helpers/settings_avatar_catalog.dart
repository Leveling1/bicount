import 'package:bicount/core/constants/constants.dart';

class SettingsAvatarCatalog {
  static final String _basePath = Constants.memojiDefault.replaceFirst(
    'memoji_default.png',
    '',
  );

  static final List<String> avatarUrls = [
    '${_basePath}memoji_1.png',
    '${_basePath}memoji_2.png',
    '${_basePath}memoji_3.png',
    '${_basePath}memoji_4.png',
    '${_basePath}memoji_5.png',
    Constants.memojiDefault,
    '${_basePath}memoji_7.png',
  ];
}
