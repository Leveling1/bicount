import 'dart:async';

import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/debt_local_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart';

class LocalDebtDataSourceImpl implements DebtLocalDataSource {
  @override
  Future<void> createDebt(DebtModel debt) async {
    await Repository().sqliteProvider.upsert<DebtModel>(
      debt,
      repository: Repository(),
    );
    unawaited(
      // ignore: body_might_complete_normally_catch_error
      Repository().upsert<DebtModel>(debt).catchError((e) {
        debugPrint('Background debt sync: $e');
      }),
    );
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    await Repository().sqliteProvider.upsert<DebtModel>(
      debt,
      repository: Repository(),
    );
    unawaited(
      // ignore: body_might_complete_normally_catch_error
      Repository().upsert<DebtModel>(debt).catchError((e) {
        debugPrint('Background debt update sync: $e');
      }),
    );
  }

  @override
  Future<void> deleteDebt(String debtId) async {
    final existing = await findDebtById(debtId);
    if (existing != null) {
      await Repository().delete<DebtModel>(existing);
    }
  }

  @override
  Future<DebtModel?> findDebtById(String debtId) async {
    if (debtId.isEmpty) {
      return null;
    }

    final items = await Repository().get<DebtModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('debtId', debtId)]),
    );
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  ) async {
    if (principalTransactionId.isEmpty) {
      return null;
    }

    final items = await Repository().get<DebtModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [Where.exact('principalTransactionId', principalTransactionId)],
      ),
    );
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<List<DebtModel>> getAllDebts() {
    return Repository().get<DebtModel>(policy: OfflineFirstGetPolicy.localOnly);
  }
}
