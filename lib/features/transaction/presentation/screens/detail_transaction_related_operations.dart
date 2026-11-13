part of 'detail_transaction_screen.dart';

extension on _DetailTransactionScreenState {
  DebtModel? get _principalDebt {
    for (final debt in widget.transaction.debts) {
      if (debt.principalTransactionId ==
          widget.transaction.transactionDetail.tid) {
        return debt;
      }
    }

    return null;
  }

  bool _isOpenDebt(DebtModel debt) {
    return debt.remainingAmount > 0 && AppDebtState.isOpen(debt.status);
  }

  /// Debt this transaction belongs to, whether it opened it or repays it.
  /// A repayment shows its parent debt's progress, which is exactly the
  /// context someone looking at that payment wants.
  DebtModel? get _relatedDebt {
    final principal = _principalDebt;
    if (principal != null) {
      return principal;
    }

    final originId = widget.transaction.transactionDetail.originId;
    if (originId == null || originId.isEmpty) {
      return null;
    }

    for (final debt in widget.transaction.debts) {
      if (debt.debtId == originId) {
        return debt;
      }
    }

    return null;
  }

  void _openDebtDetail(
    BuildContext context,
    DebtModel debt,
    DebtState debtState,
  ) {
    final mainState = context.read<MainBloc>().state;
    if (mainState is! MainLoaded) {
      return;
    }

    final dashboard = const DebtViewService().build(
      currentUserId: mainState.startData.user.uid,
      currentUserName: mainState.startData.user.username,
      friends: mainState.startData.friends,
      debts: mainState.startData.debts,
    );
    final summary = dashboard.findById(debt.debtId ?? '');
    if (summary == null) {
      return;
    }

    showDebtDetailSheet(
      context: context,
      summary: summary,
      debtState: debtState,
      state: mainState,
    );
  }

  // A salary transaction is only ever recorded once its occurrence has
  // already been confirmed, so this looks for the *next* occurrence of the
  // same recurring plan that is still awaiting confirmation.
  SalaryOccurrenceEntity? _findPendingSalaryOccurrence(BuildContext context) {
    final transactionDetail = widget.transaction.transactionDetail;
    if (transactionDetail.type != TransactionTypes.salaryCode) {
      return null;
    }

    final originId = transactionDetail.originId;
    if (originId == null || originId.isEmpty) {
      return null;
    }

    final mainState = context.read<MainBloc>().state;
    if (mainState is! MainLoaded) {
      return null;
    }

    final currencyConfig = context.read<CurrencyCubit>().state.config;
    final dashboard = const SalaryDashboardBuilder().build(
      recurringTransferts: mainState.startData.recurringTransferts,
      transactions: mainState.startData.transactions,
      currencyConfig: currencyConfig,
    );

    for (final occurrence in dashboard.attentionOccurrences) {
      if (occurrence.recurringTransfert.recurringTransfertId == originId) {
        return occurrence;
      }
    }
    return null;
  }

  bool get _isDebtRepayment {
    final originId = widget.transaction.transactionDetail.originId;
    if (originId == null || originId.isEmpty) {
      return false;
    }

    for (final debt in widget.transaction.debts) {
      if (debt.debtId == originId &&
          debt.principalTransactionId !=
              widget.transaction.transactionDetail.tid) {
        return true;
      }
    }

    return false;
  }
}
