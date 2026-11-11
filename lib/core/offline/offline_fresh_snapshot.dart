/// Wait for an older pull, then start a fresh one after a journal watermark.
Future<void> refreshAfterOlderPull({
  required Future<void>? olderPull,
  required bool Function() isCurrentAccount,
  required Future<void> Function() refresh,
}) async {
  if (olderPull != null) {
    try {
      await olderPull;
    } catch (_) {
      // The new pull still gets its own chance after an older failure.
    }
  }
  if (!isCurrentAccount()) {
    throw StateError('Account changed before journal snapshot.');
  }
  await refresh();
}
