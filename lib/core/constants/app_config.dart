class AppConfig {
  const AppConfig._();

  static const exposeCompanySurface = bool.fromEnvironment(
    'BICOUNT_ENABLE_COMPANY_SURFACE',
    defaultValue: false,
  );

  static const inviteBaseUrl = String.fromEnvironment(
    'BICOUNT_INVITE_BASE_URL',
    defaultValue: 'https://bicount.levelingcoder.com',
  );

  static const invitePath = '/friend/invite';

  static String buildInviteUrl(String inviteCode) {
    return '$inviteBaseUrl$invitePath?code=$inviteCode';
  }
}
