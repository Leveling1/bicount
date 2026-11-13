part of 'debt_repository_impl.dart';

extension on DebtRepositoryImpl {
  Future<DebtModel> _rebuildDebtFromTransactions(DebtModel debt) async {
    final repaidAmount = await _sumLinkedRepaymentsInDebtCurrency(debt);

    final remainingAmount =
        (debt.expectedRepaymentAmount - repaidAmount).clamp(0, double.infinity)
            as double;
    final nextStatus = _resolveStatus(debt, remainingAmount);
    final closedAt = remainingAmount == 0
        ? DateTime.now().toIso8601String()
        : null;

    return DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      lenderWalletId: debt.lenderWalletId,
      borrowerId: debt.borrowerId,
      borrowerWalletId: debt.borrowerWalletId,
      principalTransactionId: debt.principalTransactionId,
      title: debt.title,
      note: debt.note,
      currency: debt.currency,
      principalAmount: debt.principalAmount,
      expectedRepaymentAmount: debt.expectedRepaymentAmount,
      repaidAmount: repaidAmount,
      remainingAmount: remainingAmount,
      dueDate: debt.dueDate,
      status: nextStatus,
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: closedAt,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  int _resolveStatus(DebtModel debt, double remainingAmount) {
    if (remainingAmount == 0) {
      return AppDebtState.paid;
    }

    final dueDate = DateTime.tryParse(debt.dueDate);
    final isOverdue =
        dueDate != null &&
        DateTime.now().isAfter(dueDate.add(const Duration(days: 1)));
    if (isOverdue) {
      return AppDebtState.overdue;
    }

    return repaidState(debt.expectedRepaymentAmount, remainingAmount);
  }

  int repaidState(double expectedAmount, double remainingAmount) {
    if (remainingAmount == expectedAmount) {
      return AppDebtState.active;
    }
    return AppDebtState.partial;
  }
}
