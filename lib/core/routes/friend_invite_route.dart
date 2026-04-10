import 'package:bicount/core/constants/app_config.dart';

class FriendInviteRoute {
  const FriendInviteRoute._();

  static const embeddedQueryParam = 'embedded';

  static String? inviteCodeFromUri(Uri uri) {
    final inviteCode =
        uri.queryParameters[AppConfig.inviteCodeQueryParam] ??
        uri.queryParameters['code'];
    if (inviteCode == null) {
      return null;
    }

    final normalizedCode = inviteCode.trim();
    return normalizedCode.isEmpty ? null : normalizedCode;
  }

  static bool isInvitePath(Uri uri) => uri.path == AppConfig.invitePath;

  static bool isEmbedded(Uri uri) =>
      uri.queryParameters[embeddedQueryParam] == '1';

  static String buildAuthRoute({required String inviteCode, String? email}) {
    return Uri(
      path: email == null ? '/auth' : '/auth/email-code',
      queryParameters: {
        AppConfig.inviteCodeQueryParam: inviteCode,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    ).toString();
  }

  static String buildShellRoute(String inviteCode) {
    return Uri(
      path: '/',
      queryParameters: {AppConfig.inviteCodeQueryParam: inviteCode},
    ).toString();
  }

  static String buildSecondaryRoute(String inviteCode) {
    return Uri(
      path: AppConfig.invitePath,
      queryParameters: {
        AppConfig.inviteCodeQueryParam: inviteCode,
        embeddedQueryParam: '1',
      },
    ).toString();
  }

  static bool matches(Uri uri, String inviteCode) {
    return inviteCodeFromUri(uri) == inviteCode;
  }
}
