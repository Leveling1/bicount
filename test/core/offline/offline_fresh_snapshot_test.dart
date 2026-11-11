import 'dart:async';

import 'package:bicount/core/offline/offline_fresh_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an older pull is never reused as the journal snapshot', () async {
    final older = Completer<void>();
    var refreshCount = 0;
    final result = refreshAfterOlderPull(
      olderPull: older.future,
      isCurrentAccount: () => true,
      refresh: () async => refreshCount++,
    );
    expect(refreshCount, 0);
    older.complete();
    await result;
    expect(refreshCount, 1);
  });

  test('account change stops a fresh pull after the old one', () async {
    final older = Completer<void>();
    var current = true;
    final result = refreshAfterOlderPull(
      olderPull: older.future,
      isCurrentAccount: () => current,
      refresh: () async => fail('Should not refresh after account change'),
    );
    current = false;
    older.complete();
    await expectLater(result, throwsStateError);
  });
}
