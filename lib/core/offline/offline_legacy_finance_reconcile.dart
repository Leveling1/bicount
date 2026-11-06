import 'dart:convert';

import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'legacy_account_funding_adapter.dart';
import 'legacy_recurring_adapter.dart';
import 'offline_codecs.g.dart';
import 'outbox/offline_operation.dart';

/// Resolves copied V1 rows against rows already migrated by Supabase before
/// an old pending edit can be sent under a second UUID.
Future<void> reconcileLegacyFinanceCandidates({
  required Database db,
  required OfflineCodec<dynamic> codec,
  required String userId,
  required List<Map<String, dynamic>> remoteRows,
}) async {
  final candidates = await db.query(
    'bicount_legacy_finance_candidates',
    where: 'target_table = ?',
    whereArgs: [codec.table],
  );
  final usedRemoteIds = <String>{};
  for (final candidate in candidates) {
    final localId = candidate['target_id']?.toString();
    if (localId == null) continue;
    final localRows = await db.query(
      codec.localTable,
      where: '"${codec.localKey}" = ?',
      whereArgs: [localId],
      limit: 1,
    );
    final pendingRows = await db.query(
      'bicount_sync_outbox',
      where: 'user_id = ? AND collection = ? AND record_id = ?',
      whereArgs: [userId, codec.table, localId],
      limit: 1,
    );
    Map<String, dynamic>? local = localRows.isEmpty
        ? null
        : codec.encodeRemote(codec.decodeLocal(localRows.single));
    if (local == null &&
        pendingRows.isNotEmpty &&
        pendingRows.single['action'] == 'delete') {
      final legacy = legacyOfflineCodecs
          .where((item) => item.localTable == candidate['source_table'])
          .firstOrNull;
      if (legacy != null) {
        final sourceRows = await db.query(
          legacy.localTable,
          where: '"${legacy.localKey}" = ?',
          whereArgs: [candidate['source_id']],
          limit: 1,
        );
        if (sourceRows.isNotEmpty) {
          final source = legacy.decodeLocal(sourceRows.single);
          final canonical = switch (source) {
            AccountFundingModel funding => fundingAsTransaction(funding),
            RecurringFundingModel funding => fundingPlanAsRecurring(funding),
            SubscriptionModel subscription => subscriptionAsRecurring(
              subscription,
            ),
            _ => null,
          };
          if (canonical != null) local = codec.encodeRemote(canonical);
        }
      }
    }
    final fingerprint = local;
    final matches = remoteRows
        .where((remote) {
          final remoteId = remote[codec.key]?.toString();
          return remoteId != null &&
              !usedRemoteIds.contains(remoteId) &&
              (remoteId == localId ||
                  (fingerprint != null &&
                      _sameMigratedRow(codec.table, fingerprint, remote)));
        })
        .toList(growable: false);
    if (matches.length > 1) {
      throw StateError(
        'Ambiguous legacy finance identity for ${codec.table}/$localId',
      );
    }
    final matching = matches.firstOrNull;
    final remoteId = matching?[codec.key]?.toString();
    if (remoteId != null) usedRemoteIds.add(remoteId);
    await db.transaction((tx) async {
      if (remoteId != null && remoteId != localId) {
        if (pendingRows.isNotEmpty) {
          final pending = pendingRows.single;
          final action = pending['action']?.toString();
          final payload = action == 'delete'
              ? <String, Object?>{codec.key: remoteId}
              : <String, Object?>{
                  ...(jsonDecode(pending['payload'] as String) as Map)
                      .cast<String, Object?>(),
                  codec.key: remoteId,
                };
          await tx.update(
            'bicount_sync_outbox',
            {'record_id': remoteId, 'payload': jsonEncode(payload)},
            where: 'sequence = ?',
            whereArgs: [pending['sequence']],
          );
          if (localRows.isNotEmpty && action != 'delete') {
            final migrated = Map<String, Object?>.from(localRows.single)
              ..remove('_brick_id')
              ..remove('_local_id')
              ..[codec.localKey] = remoteId;
            await tx.insert(
              codec.localTable,
              migrated,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        await tx.delete(
          codec.localTable,
          where: '"${codec.localKey}" = ?',
          whereArgs: [localId],
        );
      } else if (remoteId == null &&
          localRows.isNotEmpty &&
          local != null &&
          pendingRows.isEmpty) {
        final operation = OfflineOperation(
          userId: userId,
          collection: codec.table,
          recordId: localId,
          action: 'upsert',
          payload: local,
        );
        await tx.insert('bicount_sync_outbox', operation.toDatabase());
      }
      await tx.delete(
        'bicount_legacy_finance_candidates',
        where: 'source_table = ? AND source_id = ?',
        whereArgs: [candidate['source_table'], candidate['source_id']],
      );
    });
  }
}

bool _sameMigratedRow(
  String table,
  Map<String, dynamic> local,
  Map<String, dynamic> remote,
) {
  if (table == 'transactions') {
    final amountA = (local['amount'] as num?)?.toDouble();
    final amountB = (remote['amount'] as num?)?.toDouble();
    return local['uid'] == remote['uid'] &&
        local['type'] == remote['type'] &&
        local['name'] == remote['name'] &&
        local['currency'] == remote['currency'] &&
        amountA != null &&
        amountB != null &&
        (amountA - amountB).abs() < 0.000001 &&
        _day(local['date']) == _day(remote['date']) &&
        remote['sender_id'] == remote['uid'] &&
        remote['beneficiary_id'] == remote['uid'];
  }
  if (table == 'recurring_transfert') {
    return local['uid'] == remote['uid'] &&
        local['transaction_type'] == remote['transaction_type'] &&
        local['title'] == remote['title'] &&
        local['amount'] == remote['amount'] &&
        local['currency'] == remote['currency'] &&
        _day(local['start_date']) == _day(remote['start_date']);
  }
  return false;
}

String? _day(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.length < 10) return raw;
  return raw.substring(0, 10);
}
