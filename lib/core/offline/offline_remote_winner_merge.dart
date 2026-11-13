import 'package:sqflite_common/sqlite_api.dart';

import 'offline_codecs.g.dart';
import 'offline_merge.dart';
import 'offline_remote_winner.dart';
import 'outbox/offline_operation.dart';

/// Applies a verified server winner without bypassing normal merge protections.
/// The caller must first establish a trustworthy ordering and server watermark.
Future<bool> mergeRemoteConflictWinner({
  required Database db,
  required OfflineOperation operation,
  required OfflineCodec<dynamic> codec,
  required Map<String, dynamic>? remoteRow,
  required int journalSequence,
  required int journalGeneration,
  required String? Function() currentUserId,
}) {
  if (operation.collection != codec.table ||
      (operation.action != 'upsert' && operation.action != 'delete') ||
      (remoteRow != null &&
          remoteRow[codec.key]?.toString() != operation.recordId) ||
      journalSequence < 0 ||
      journalGeneration <= 0) {
    throw ArgumentError('Invalid conflict winner or journal marker.');
  }
  void checkUser() {
    if (currentUserId() != operation.userId) {
      throw StateError('Account changed during conflict resolution.');
    }
  }

  checkUser();
  return applyRemoteConflictWinner(
    db: db,
    operation: operation,
    remoteRow: remoteRow,
    applyRemote: (tx) async {
      checkUser();
      final applied = await const OfflineMerge().eventInTransaction(
        tx: tx,
        codec: codec,
        userId: operation.userId,
        id: operation.recordId,
        row: remoteRow,
        observedSequence: journalSequence,
        observedGeneration: journalGeneration,
      );
      if (!applied) throw StateError('Conflict record remains protected.');
      checkUser();
    },
  );
}
