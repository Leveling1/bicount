part of 'detail_transaction_screen.dart';

extension on _DetailTransactionScreenState {
  Future<void> _confirmDebtDelete(BuildContext context, DebtModel debt) async {
    confirmDelete(
      context,
      title: context.l10n.debtDeleteConfirmTitle,
      description: context.l10n.debtDeleteConfirmDescription,
      onConfirm: () {
        context.read<DebtBloc>().add(DeleteDebtRequested(debt.debtId ?? ''));
      },
    );
  }

  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (state is TransactionDeleted) {
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(
          context,
          context.l10n.transactionDeletedSuccess,
        );
        Navigator.of(context).maybePop();
      });
      return;
    }

    if (state is TransactionError) {
      _runAfterFrame(() {
        NotificationHelper.showFailureNotification(
          context,
          localizeRuntimeMessage(context, state.failure.message),
        );
      });
    }
  }

  void _onDebtStateChanged(BuildContext context, DebtState state) {
    if (state is DebtActionSuccess) {
      final message = switch (state.message) {
        'Debt contract updated.' => context.l10n.debtUpdatedSuccess,
        'Debt contract deleted.' => context.l10n.debtDeletedSuccess,
        _ => state.message,
      };
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(context, message);
        Navigator.of(context).maybePop();
      });
      return;
    }

    if (state is DebtActionFailure) {
      _runAfterFrame(() {
        NotificationHelper.showFailureNotification(
          context,
          localizeRuntimeMessage(context, state.message),
        );
      });
    }
  }

  String _resolveCounterpartyName(DebtModel debt) {
    final currentUserId = widget.transaction.user.uid;
    final currentUserName = widget.transaction.user.username;
    final partyId = debt.lenderId == currentUserId
        ? debt.borrowerId
        : debt.lenderId;
    if (partyId == currentUserId) {
      return currentUserName;
    }

    for (final friend in widget.transaction.friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        return friend.username;
      }
    }

    return partyId;
  }

  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      action();
    });
  }
}
