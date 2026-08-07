import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_transaction_classifier.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class AnalysisTransactionBreakdownMatcher {
  const AnalysisTransactionBreakdownMatcher({
    required this.debtClassifier,
    required this.currentUserParticipantIds,
    this.knownFriendParticipantIds = const {},
    this.identityService = const TransactionParticipantIdentityService(),
  });

  final AnalysisDebtTransactionClassifier debtClassifier;
  final Set<String>? currentUserParticipantIds;
  final Set<String> knownFriendParticipantIds;
  final TransactionParticipantIdentityService identityService;

  /// Whether the current user is the beneficiary of [transaction], matching
  /// directly first and falling back to elimination against known friend
  /// identifiers — see [TransactionParticipantIdentityService.
  /// isMineWithFallback] for why a transaction recorded from a linked
  /// friend's device may reference the current user with an id this device
  /// has never seen.
  bool _isCurrentUserBeneficiary(TransactionModel transaction) {
    final participantIds = currentUserParticipantIds;
    if (participantIds == null) {
      return false;
    }
    return identityService.isMineWithFallback(
      candidateId: transaction.beneficiaryId,
      counterpartId: transaction.senderId,
      currentUserParticipantIds: participantIds,
      knownFriendParticipantIds: knownFriendParticipantIds,
    );
  }

  bool _isCurrentUserSender(TransactionModel transaction) {
    final participantIds = currentUserParticipantIds;
    if (participantIds == null) {
      return false;
    }
    return identityService.isMineWithFallback(
      candidateId: transaction.senderId,
      counterpartId: transaction.beneficiaryId,
      currentUserParticipantIds: participantIds,
      knownFriendParticipantIds: knownFriendParticipantIds,
    );
  }

  bool matchesGenericIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserBeneficiary(transaction) &&
          transaction.type == TransactionTypes.incomeCode;
    }

    return transaction.type == TransactionTypes.incomeCode;
  }

  bool matchesSalary(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserBeneficiary(transaction) &&
          transaction.type == TransactionTypes.salaryCode;
    }

    return transaction.type == TransactionTypes.salaryCode;
  }

  bool matchesDebtIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserBeneficiary(transaction) &&
          debtClassifier.isPrincipalTransaction(transaction);
    }

    return false;
  }

  bool matchesDebtRepaymentIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserBeneficiary(transaction) &&
          debtClassifier.isRepaymentTransaction(transaction);
    }

    return false;
  }

  bool matchesOtherIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserBeneficiary(transaction) &&
          (transaction.type == TransactionTypes.otherRecurringIncomeCode ||
              transaction.type == TransactionTypes.othersCode);
    }

    return transaction.type == TransactionTypes.otherRecurringIncomeCode;
  }

  bool matchesGenericExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserSender(transaction) &&
          transaction.type == TransactionTypes.expenseCode;
    }

    return transaction.type == TransactionTypes.expenseCode;
  }

  bool matchesSubscription(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserSender(transaction) &&
          transaction.type == TransactionTypes.subscriptionCode;
    }

    return transaction.type == TransactionTypes.subscriptionCode;
  }

  bool matchesDebtExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserSender(transaction) &&
          debtClassifier.isPrincipalTransaction(transaction);
    }

    return false;
  }

  bool matchesDebtRepaymentExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserSender(transaction) &&
          debtClassifier.isRepaymentTransaction(transaction);
    }

    return false;
  }

  bool matchesOtherExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return _isCurrentUserSender(transaction) &&
          (transaction.type == TransactionTypes.otherRecurringExpenseCode ||
              transaction.type == TransactionTypes.othersCode);
    }

    return transaction.type == TransactionTypes.otherRecurringExpenseCode ||
        transaction.type == TransactionTypes.othersCode;
  }
}
