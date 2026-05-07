import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/debt_local_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';

class LocalDebtDataSourceImpl implements DebtLocalDataSource {
  @override
  Future<void> createDebt(DebtModel debt) {
    return Repository().upsert<DebtModel>(debt);
  }

  @override
  Future<void> updateDebt(DebtModel debt) {
    return Repository().upsert<DebtModel>(debt);
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
