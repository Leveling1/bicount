import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';

class AnalysisDebtBalanceResolver {
  const AnalysisDebtBalanceResolver({
    required this.currentUserParticipantIds,
    this.knownFriendParticipantIds = const {},
    this.currencyAmountService = const CurrencyAmountService(),
    this.identityService = const TransactionParticipantIdentityService(),
  });

  final Set<String>? currentUserParticipantIds;
  final Set<String> knownFriendParticipantIds;
  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService identityService;

  double receivableBalance(
    List<DebtModel> debts,
    CurrencyConfigEntity currencyConfig,
  ) {
    return _sumDebtBalances(debts, currencyConfig, (debt) {
      return _isOpenDebt(debt) &&
          _isMine(candidateId: debt.lenderId, counterpartId: debt.borrowerId);
    });
  }

  double payableBalance(
    List<DebtModel> debts,
    CurrencyConfigEntity currencyConfig,
  ) {
    return _sumDebtBalances(debts, currencyConfig, (debt) {
      return _isOpenDebt(debt) &&
          _isMine(candidateId: debt.borrowerId, counterpartId: debt.lenderId);
    });
  }

  /// Whether [candidateId] (a debt's lender or borrower) is the current
  /// user, matching directly first and falling back to elimination against
  /// known friend identifiers — see [TransactionParticipantIdentityService.
  /// isMineWithFallback] for why a debt recorded from a linked friend's
  /// device may reference the current user with an id this device has
  /// never seen.
  bool _isMine({required String candidateId, required String counterpartId}) {
    final participantIds = currentUserParticipantIds;
    if (participantIds == null) {
      return false;
    }
    return identityService.isMineWithFallback(
      candidateId: candidateId,
      counterpartId: counterpartId,
      currentUserParticipantIds: participantIds,
      knownFriendParticipantIds: knownFriendParticipantIds,
    );
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
