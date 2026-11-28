abstract interface class WhatsNewRepository {
  Future<bool> wasDismissed(String releaseId);
  Future<void> markDismissed(String releaseId);
}
