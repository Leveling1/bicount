import 'package:bicount/features/debt/data/models/debt.model.dart';

abstract class DebtLocalDataSource {
  Future<void> createDebt(DebtModel debt);
  Future<void> updateDebt(DebtModel debt);
  Future<void> deleteDebt(String debtId);
  Future<DebtModel?> findDebtById(String debtId);
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  );
  Future<List<DebtModel>> getAllDebts();
}
