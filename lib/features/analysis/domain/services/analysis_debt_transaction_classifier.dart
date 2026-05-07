import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class AnalysisDebtTransactionClassifier {
  AnalysisDebtTransactionClassifier(Iterable<DebtModel> debts)
    : _debtIds = {
        for (final debt in debts)
          if ((debt.debtId ?? '').isNotEmpty) debt.debtId!,
      },
      _principalTransactionIds = {
        for (final debt in debts)
          if (debt.principalTransactionId.isNotEmpty)
            debt.principalTransactionId,
      };

  final Set<String> _debtIds;
  final Set<String> _principalTransactionIds;

  bool isPrincipalTransaction(TransactionModel transaction) {
    return transaction.type == TransactionTypes.debtCode &&
        transaction.tid != null &&
        _principalTransactionIds.contains(transaction.tid);
  }

  bool isRepaymentTransaction(TransactionModel transaction) {
    final originId = transaction.originId;
    return transaction.type == TransactionTypes.debtCode &&
        !isPrincipalTransaction(transaction) &&
        originId != null &&
        _debtIds.contains(originId);
  }
}
