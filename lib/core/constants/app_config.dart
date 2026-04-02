class AppConfig {
  const AppConfig._();

  static const appScheme = 'bicount';

  static const exposeCompanySurface = bool.fromEnvironment(
    'BICOUNT_ENABLE_COMPANY_SURFACE',
    defaultValue: false,
  );

  static const inviteBaseUrl = String.fromEnvironment(
    'BICOUNT_INVITE_BASE_URL',
    defaultValue: 'https://bicount.levelingcoder.com',
  );

  static const invitePath = '/friend/invite';
  static const inviteCodeQueryParam = 'inviteCode';
  static const authPath = '/auth';
  static const consumerTermsPath = '/consumer-terms';
  static const usagePolicyPath = '/usage-policy';
  static const privacyPolicyPath = '/privacy-policy';

  static String buildInviteUrl(String inviteCode) {
    return '$inviteBaseUrl$invitePath?$inviteCodeQueryParam=$inviteCode';
  }

  static String buildInviteSchemeUrl(String inviteCode) {
    return '$appScheme://friend/invite?$inviteCodeQueryParam=$inviteCode';
  }

  static String get authUrl => '$inviteBaseUrl$authPath';

  static String get consumerTermsUrl => '$inviteBaseUrl$consumerTermsPath';

  static String get usagePolicyUrl => '$inviteBaseUrl$usagePolicyPath';

  static String get privacyPolicyUrl => '$inviteBaseUrl$privacyPolicyPath';
}
