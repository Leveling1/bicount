import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'legacy_account_funding_adapter.dart';
import 'legacy_recurring_adapter.dart';
import 'offline_codecs.g.dart';

/// Copies old finance rows into the unified local ledger without deleting V1
/// data or sending anything to Supabase. Reconciliation decides remote identity.
Future<void> migrateLegacyFinance(Database db, String uid) async {
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_legacy_finance_imported '
    '(source_table TEXT NOT NULL, source_id TEXT NOT NULL, '
    'PRIMARY KEY (source_table, source_id))',
  );
  await db.execute(
    'CREATE TABLE IF NOT EXISTS bicount_legacy_finance_candidates '
    '(source_table TEXT NOT NULL, source_id TEXT NOT NULL, '
    'target_table TEXT NOT NULL, target_id TEXT NOT NULL, '
    'PRIMARY KEY (source_table, source_id))',
  );
  for (final legacy in legacyOfflineCodecs) {
    final exists = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [legacy.localTable],
    );
    if (exists.isEmpty) continue;
    final sourceRows = await db.query(legacy.localTable);
    for (final source in sourceRows) {
      final model = legacy.decodeLocal(source);
      final owner = switch (model) {
        AccountFundingModel funding => funding.sid,
        RecurringFundingModel funding => funding.uid,
        SubscriptionModel subscription => subscription.sid,
        _ => '',
      };
      if (owner != uid) continue;
      final target = switch (model) {
        AccountFundingModel funding => fundingAsTransaction(funding),
        RecurringFundingModel funding => fundingPlanAsRecurring(funding),
        SubscriptionModel subscription => subscriptionAsRecurring(subscription),
        _ => throw StateError('Unknown legacy finance row.'),
      };
      final targetCodec = target is TransactionModel
          ? transactionModelCodec
          : recurringTransfertModelCodec;
      final sourceId = source[legacy.localKey]?.toString();
      final targetId = targetCodec
          .encodeLocal(target)[targetCodec.localKey]
          ?.toString();
      if (sourceId == null || targetId == null) continue;
      await db.transaction((tx) async {
        final imported = await tx.query(
          'bicount_legacy_finance_imported',
          where: 'source_table = ? AND source_id = ?',
          whereArgs: [legacy.localTable, sourceId],
          limit: 1,
        );
        if (imported.isNotEmpty) return;
        final existing = await tx.query(
          targetCodec.localTable,
          where: '"${targetCodec.localKey}" = ?',
          whereArgs: [targetId],
          limit: 1,
        );
        if (existing.isEmpty) {
          await tx.insert(
            targetCodec.localTable,
            targetCodec.encodeLocal(target),
          );
          await tx.insert('bicount_legacy_finance_candidates', {
            'source_table': legacy.localTable,
            'source_id': sourceId,
            'target_table': targetCodec.table,
            'target_id': targetId,
          });
        }
        await tx.insert('bicount_legacy_finance_imported', {
          'source_table': legacy.localTable,
          'source_id': sourceId,
        });
      });
    }
  }
}

Future<bool> hasLegacyFinanceCandidates(Database db) async {
  final tables = await db.rawQuery(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' "
    "AND name = 'bicount_legacy_finance_candidates'",
  );
  if (tables.isEmpty) return false;
  return (await db.query(
    'bicount_legacy_finance_candidates',
    limit: 1,
  )).isNotEmpty;
}
