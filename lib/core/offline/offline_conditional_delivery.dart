import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_conditional_acknowledgement.dart';
import 'offline_conditional_mutation.dart';
import 'offline_conflict_archive.dart';
import 'outbox/offline_operation.dart';
import 'outbox/offline_outbox.dart';

/// One experimental attempt. No error or conflict falls back to a blind write.
Future<void> deliverConditionalOperation({
  required Database db,
  required SupabaseClient client,
  required OfflineOperation operation,
  required String? Function() currentUserId,
}) async {
  final outcome = await sendConditionalMutation(
    db: db,
    client: client,
    operation: operation,
    currentUserId: currentUserId,
  );
  if (outcome.result == ConditionalMutationResult.applied) {
    await acknowledgeConditionalMutation(
      db: db,
      operation: operation,
      remoteRow: outcome.remoteRow,
      journalSequence: outcome.journalSequence!,
      journalGeneration: outcome.journalGeneration!,
    );
    return;
  }
  await archiveConditionalConflict(
    db: db,
    operation: operation,
    reason: outcome.result.name,
    remoteRow: outcome.remoteRow,
  );
  await OfflineOutbox(db).defer(
    operation.userId,
    operation.id,
    StateError('Conditional mutation ${outcome.result.name}'),
    attempts: operation.attempts + 1,
  );
}
