import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

import 'legacy_account_funding_adapter.dart';
import 'legacy_recurring_adapter.dart';
import 'legacy_uuid.dart';
import 'offline_codecs.g.dart';
import 'offline_legacy_owner.dart';
import 'outbox/offline_operation.dart';
import 'outbox/offline_outbox.dart';

/// Rebuilds outstanding intents from the previous HTTP queue without replaying
/// stale credentials or removing the source queue. Each record keeps its final
/// local state, so repeated migration and delivery are idempotent.
Future<void> importLegacyQueue(
  Database target,
  DatabaseFactory factory,
  String uid,
  String directory,
) async {
  final sourcePath = path.join(directory, 'brick_offline_queue.sqlite');
  final modelPath = path.join(directory, 'my_repository.sqlite');
  if (!await factory.databaseExists(sourcePath) ||
      !await legacyDatabaseBelongsTo(factory, modelPath, uid)) {
    return;
  }

  final queueDb = await factory.openDatabase(
    sourcePath,
    options: OpenDatabaseOptions(readOnly: true),
  );
  try {
    final tables = await queueDb.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'HttpJobs'",
    );
    if (tables.isEmpty) return;
    final jobs = await queueDb.query('HttpJobs', orderBy: 'created_at, id');
    await target.execute(
      'CREATE TABLE IF NOT EXISTS bicount_legacy_import '
      '(job_id INTEGER PRIMARY KEY)',
    );
    for (final job in jobs) {
      final jobId = job['id'] as int;
      final imported = await target.query(
        'bicount_legacy_import',
        where: 'job_id = ?',
        whereArgs: [jobId],
        limit: 1,
      );
      if (imported.isNotEmpty) continue;
      final queuedOwner = _requestOwner(job['headers'] as String?);
      if (queuedOwner != null && queuedOwner != uid) {
        // A shared V1 HTTP queue can contain a previous account's request.
        continue;
      }
      final method = (job['request_method'] as String? ?? '').toUpperCase();
      if (!{'POST', 'PUT', 'PATCH', 'DELETE'}.contains(method)) {
        await target.insert('bicount_legacy_import', {'job_id': jobId});
        continue;
      }
      final url = Uri.tryParse(job['url'] as String? ?? '');
      if (url == null) throw StateError('Invalid queued URL at job $jobId');
      final table = url.pathSegments.isEmpty ? '' : url.pathSegments.last;
      final matches = [
        ...allOfflineCodecs,
        ...legacyOfflineCodecs,
      ].where((codec) => codec.table == table);
      final codec = matches.isEmpty ? null : matches.single;
      final isRetiredTable = legacyOfflineCodecs.contains(codec);
      final body = job['body'] is String && (job['body'] as String).isNotEmpty
          ? jsonDecode(job['body'] as String)
          : null;
      final payloads = body is List ? body : [body];
      final ids = <String>{};
      if (codec != null) {
        for (final payload in payloads) {
          if (payload is Map && payload[codec.key] != null) {
            ids.add(payload[codec.key].toString());
          }
        }
        final filter = url.queryParameters[codec.key];
        if (filter != null && filter.startsWith('eq.')) {
          ids.add(filter.substring(3));
        }
      }
      if (ids.isEmpty) {
        if (isRetiredTable) {
          throw StateError('Cannot safely migrate legacy $table job $jobId.');
        }
        final raw = OfflineOperation(
          userId: uid,
          collection: 'legacy_http',
          recordId: jobId.toString(),
          action: 'legacy_http',
          payload: {
            'url': url.toString(),
            'method': method,
            'body': job['body'] as String? ?? '',
            'headers': job['headers'] as String? ?? '{}',
          },
        );
        await OfflineOutbox(target).commit(raw, (tx) async {
          await tx.insert('bicount_legacy_import', {'job_id': jobId});
        });
        continue;
      }
      final knownCodec = codec!;
      for (final id in ids) {
        final local = await target.query(
          knownCodec.localTable,
          where: '"${knownCodec.localKey}" = ?',
          whereArgs: [id],
          limit: 1,
        );
        final Object? canonical = local.isEmpty
            ? null
            : _canonicalFinanceRow(knownCodec.decodeLocal(local.single));
        final targetCodec = canonical is TransactionModel
            ? transactionModelCodec
            : canonical != null
            ? recurringTransfertModelCodec
            : table == 'account_funding'
            ? transactionModelCodec
            : table == 'subscriptions' || table == 'recurring_fundings'
            ? recurringTransfertModelCodec
            : knownCodec;
        final targetId = canonical == null
            ? (isRetiredTable ? canonicalLegacyUuid(table, id) : id)
            : targetCodec.encodeRemote(canonical)[targetCodec.key].toString();
        final operation = OfflineOperation(
          userId: uid,
          collection: targetCodec.table,
          recordId: targetId,
          action: local.isEmpty ? 'delete' : 'upsert',
          payload: local.isEmpty
              ? {targetCodec.key: targetId}
              : targetCodec.encodeRemote(
                  canonical ?? knownCodec.decodeLocal(local.single),
                ),
        );
        await OfflineOutbox(target).commit(operation, (_) async {});
      }
      await target.insert('bicount_legacy_import', {'job_id': jobId});
    }
  } finally {
    await queueDb.close();
  }
}

Object _canonicalFinanceRow(Object row) => switch (row) {
  AccountFundingModel funding => fundingAsTransaction(funding),
  RecurringFundingModel funding => fundingPlanAsRecurring(funding),
  SubscriptionModel subscription => subscriptionAsRecurring(subscription),
  _ => row,
};

String? _requestOwner(String? encodedHeaders) {
  if (encodedHeaders == null || encodedHeaders.isEmpty) return null;
  try {
    final headers = jsonDecode(encodedHeaders) as Map;
    String? authorization;
    for (final entry in headers.entries) {
      if (entry.key.toString().toLowerCase() == 'authorization') {
        authorization = entry.value?.toString();
      }
    }
    if (authorization == null || !authorization.startsWith('Bearer ')) {
      return null;
    }
    final token = authorization.substring(7).split('.');
    if (token.length != 3) return null;
    final claims =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(token[1]))))
            as Map;
    return claims['sub']?.toString();
  } catch (_) {
    return null;
  }
}
