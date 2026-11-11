import 'package:sqflite_common/sqlite_api.dart';

import 'offline_codecs.g.dart';

/// Resolve only identities proven by the original UUID. The historical server
/// migration assigned new UUIDs to some records without preserving a mapping;
/// matching amounts and dates is not proof and must not drive remote writes.
Future<void> reconcileLegacyFinanceCandidates({
  required Database db,
  required OfflineCodec<dynamic> codec,
  required String userId,
  required List<Map<String, dynamic>> remoteRows,
}) async {
  final remoteIds = remoteRows
      .map((row) => row[codec.key]?.toString())
      .whereType<String>()
      .toSet();
  final candidates = await db.query(
    'bicount_legacy_finance_candidates',
    where: 'target_table = ?',
    whereArgs: [codec.table],
  );
  for (final candidate in candidates) {
    final id = candidate['target_id']?.toString();
    if (id == null || !remoteIds.contains(id)) continue;
    // A matching UUID proves identity, not that a queued legacy write is
    // newer than the server. Keep that write quarantined until conflict
    // resolution can compare it safely.
    await db.rawDelete(
      'DELETE FROM bicount_legacy_finance_candidates '
      'WHERE source_table = ? AND source_id = ? AND NOT EXISTS ('
      'SELECT 1 FROM bicount_sync_outbox o '
      'WHERE o.user_id = ? AND o.collection = ? AND o.record_id = ?)',
      [
        candidate['source_table'],
        candidate['source_id'],
        userId,
        codec.table,
        id,
      ],
    );
  }
}
