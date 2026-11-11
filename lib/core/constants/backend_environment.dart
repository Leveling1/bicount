import 'package:flutter/foundation.dart';

import 'secrets.dart';

/// An explicitly enabled, loopback-only development backend.
class BackendEnvironment {
  static const isLocalPreproduction = bool.fromEnvironment(
    'BICOUNT_LOCAL_PREPROD',
  );
  static const isConditionalTest = bool.fromEnvironment(
    'BICOUNT_EXPERIMENTAL_CONDITIONAL',
  );
  static const isJournalEnabled = bool.fromEnvironment('BICOUNT_SYNC_JOURNAL');
  static const _localKey = String.fromEnvironment('BICOUNT_LOCAL_ANON_KEY');
  static const _localUrl = 'http://127.0.0.1:54321';

  static void validate() {
    if (isConditionalTest && !isLocalPreproduction) {
      throw StateError(
        'Experimental conditional sync requires local preproduction.',
      );
    }
    if (isConditionalTest && !isJournalEnabled) {
      throw StateError('Experimental conditional sync requires the journal.');
    }
    if (isLocalPreproduction && (kReleaseMode || _localKey.isEmpty)) {
      throw StateError(
        'Local preproduction requires a debug build and local key.',
      );
    }
  }

  static void validateAndroidPackage(String packageName) {
    if ((packageName == 'com.youngsolver.bicount.preprod') !=
        isLocalPreproduction) {
      throw StateError('Preproduction build and application identity differ.');
    }
  }

  static String get projectUrl =>
      isLocalPreproduction ? _localUrl : Secrets.projectUrl;
  static String get anonKey =>
      isLocalPreproduction ? _localKey : Secrets.anonKey;

  static String endpoint(String productionUrl) {
    if (!isLocalPreproduction) return productionUrl;
    final original = Uri.parse(productionUrl);
    return Uri.parse(_localUrl)
        .replace(
          path: original.path,
          query: original.hasQuery ? original.query : null,
        )
        .toString();
  }
}
