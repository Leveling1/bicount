import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_transaction_classifier.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class AnalysisTransactionBreakdownMatcher {
  const AnalysisTransactionBreakdownMatcher({
    required this.debtClassifier,
    required this.currentUserParticipantIds,
  });

  final AnalysisDebtTransactionClassifier debtClassifier;
  final Set<String>? currentUserParticipantIds;

  bool matchesGenericIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.beneficiaryId) &&
          transaction.type != TransactionTypes.salaryCode &&
          transaction.type != TransactionTypes.otherRecurringIncomeCode &&
          !debtClassifier.isRepaymentTransaction(transaction);
    }

    return transaction.type == TransactionTypes.incomeCode;
  }

  bool matchesSalary(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.beneficiaryId) &&
          transaction.type == TransactionTypes.salaryCode;
    }

    return transaction.type == TransactionTypes.salaryCode;
  }

  bool matchesDebtRepaymentIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.beneficiaryId) &&
          debtClassifier.isRepaymentTransaction(transaction);
    }

    return false;
  }

  bool matchesOtherIncome(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.beneficiaryId) &&
          transaction.type == TransactionTypes.otherRecurringIncomeCode;
    }

    return transaction.type == TransactionTypes.otherRecurringIncomeCode;
  }

  bool matchesGenericExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.senderId) &&
          transaction.type != TransactionTypes.subscriptionCode &&
          transaction.type != TransactionTypes.otherRecurringExpenseCode &&
          !debtClassifier.isPrincipalTransaction(transaction);
    }

    return transaction.type == TransactionTypes.expenseCode;
  }

  bool matchesSubscription(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.senderId) &&
          transaction.type == TransactionTypes.subscriptionCode;
    }

    return transaction.type == TransactionTypes.subscriptionCode;
  }

  bool matchesDebtExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.senderId) &&
          debtClassifier.isPrincipalTransaction(transaction);
    }

    return false;
  }

  bool matchesOtherExpense(TransactionModel transaction) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds!.contains(transaction.senderId) &&
          transaction.type == TransactionTypes.otherRecurringExpenseCode;
    }

    return transaction.type == TransactionTypes.otherRecurringExpenseCode ||
        transaction.type == TransactionTypes.othersCode;
  }
}
