class Constants {
  static const String expenseType = 'expense';
  static const String incomesType = 'income';

  /// Default memoji image URL
  static const String memojiDefault =
      bool.fromEnvironment('BICOUNT_LOCAL_PREPROD')
      ? 'http://127.0.0.1:54321/storage/v1/object/public/memoji/memoji_default.png'
      : 'https://yudjgfypbsahpukruqta.supabase.co/storage/v1/object/public/memoji/memoji_default.png';

  /// Transaction categories
  static const personal = 0;
  static const company = 1;

  /// Connectivity states
  static const int connected = 0;
  static const int disconnected = 1;
}
