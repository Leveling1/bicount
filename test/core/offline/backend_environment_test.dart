import 'package:bicount/core/constants/backend_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conditional sync cannot target a non-local backend', () {
    if (BackendEnvironment.isConditionalTest &&
        !BackendEnvironment.isLocalPreproduction) {
      expect(BackendEnvironment.validate, throwsStateError);
    }
  });

  test('conditional sync requires the journal', () {
    if (BackendEnvironment.isConditionalTest &&
        BackendEnvironment.isLocalPreproduction &&
        !BackendEnvironment.isJournalEnabled) {
      expect(BackendEnvironment.validate, throwsStateError);
    }
  });
  test('Android package must match selected environment', () {
    final correct = BackendEnvironment.isLocalPreproduction
        ? 'com.youngsolver.bicount.preprod'
        : 'com.youngsolver.bicount';
    final wrong = BackendEnvironment.isLocalPreproduction
        ? 'com.youngsolver.bicount'
        : 'com.youngsolver.bicount.preprod';
    expect(
      () => BackendEnvironment.validateAndroidPackage(correct),
      returnsNormally,
    );
    expect(
      () => BackendEnvironment.validateAndroidPackage(wrong),
      throwsStateError,
    );
  });
  test('local preproduction cannot use a production endpoint', () {
    if (!BackendEnvironment.isLocalPreproduction) return;
    BackendEnvironment.validate();
    expect(BackendEnvironment.projectUrl, 'http://127.0.0.1:54321');
    expect(
      BackendEnvironment.endpoint('https://example.com/functions/v1/test'),
      'http://127.0.0.1:54321/functions/v1/test',
    );
  });
}
