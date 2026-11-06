import 'package:bicount/core/offline/offline_model.dart';

import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/debt_local_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';

class LocalDebtDataSourceImpl implements DebtLocalDataSource {
  @override
  Future<void> createDebt(DebtModel debt) async {
    await Repository().upsert<DebtModel>(debt);
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    await Repository().upsert<DebtModel>(debt);
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
      policy: OfflineReadPolicy.localOnly,
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
      policy: OfflineReadPolicy.localOnly,
      query: Query(
        where: [Where.exact('principalTransactionId', principalTransactionId)],
      ),
    );
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<List<DebtModel>> getAllDebts() {
    return Repository().get<DebtModel>(policy: OfflineReadPolicy.localOnly);
  }
}
