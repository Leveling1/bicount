import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';

class AnalysisDebtBalanceResolver {
  const AnalysisDebtBalanceResolver({
    required this.currentUserParticipantIds,
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final Set<String>? currentUserParticipantIds;
  final CurrencyAmountService currencyAmountService;

  double receivableBalance(
    List<DebtModel> debts,
    CurrencyConfigEntity currencyConfig,
  ) {
    return _sumDebtBalances(debts, currencyConfig, (debt) {
      return _isOpenDebt(debt) &&
          currentUserParticipantIds?.contains(debt.lenderId) == true;
    });
  }

  double payableBalance(
    List<DebtModel> debts,
    CurrencyConfigEntity currencyConfig,
  ) {
    return _sumDebtBalances(debts, currencyConfig, (debt) {
      return _isOpenDebt(debt) &&
          currentUserParticipantIds?.contains(debt.borrowerId) == true;
    });
  }

  double _sumDebtBalances(
    List<DebtModel> debts,
    CurrencyConfigEntity currencyConfig,
    bool Function(DebtModel debt) predicate,
  ) {
    return debts.where(predicate).fold<double>(0, (sum, debt) {
      final anchorDate = debt.createdAt ?? debt.dueDate;
      return sum +
          currencyAmountService.record(
            originalAmount: debt.remainingAmount,
            originalCurrencyCode: debt.currency,
            fxRateDate: anchorDate,
            config: currencyConfig,
          );
    });
  }

  bool _isOpenDebt(DebtModel debt) {
    return debt.remainingAmount > 0 && AppDebtState.isOpen(debt.status);
  }
}
