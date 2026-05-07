import 'package:bicount/features/debt/domain/entities/debt_list_scope.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';

class DebtDashboardEntity {
  const DebtDashboardEntity({
    required this.receivableDebts,
    required this.payableDebts,
  });

  final List<DebtSummaryEntity> receivableDebts;
  final List<DebtSummaryEntity> payableDebts;

  List<DebtSummaryEntity> visibleDebts(DebtListScope scope) {
    return switch (scope) {
      DebtListScope.all => [...receivableDebts, ...payableDebts],
      DebtListScope.receivable => receivableDebts,
      DebtListScope.payable => payableDebts,
    };
  }

  DebtSummaryEntity? findById(String debtId) {
    for (final debt in [...receivableDebts, ...payableDebts]) {
      if (debt.debt.debtId == debtId) {
        return debt;
      }
    }
    return null;
  }
}
