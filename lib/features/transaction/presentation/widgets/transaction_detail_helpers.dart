part of 'transaction_detail_content.dart';

extension on TransactionDetailContent {
  Widget _buildDebtProgress(BuildContext context, DebtModel debt) {
    final isSettled =
        debt.remainingAmount <= 0 || !AppDebtState.isOpen(debt.status);

    if (isSettled) {
      // closedAt is stamped the moment the balance reaches zero, so it is the
      // last repayment. Older rows may predate it, hence the fallback.
      final settledOn = DateTime.tryParse(
        debt.closedAt ?? debt.updatedAt ?? '',
      );
      return DetailsCard(
        child: TransactionDetailRow(
          title: context.l10n.transactionDebtSettledOn,
          content: settledOn == null ? '-' : formatedDate(settledOn),
        ),
      );
    }

    return DetailsCard(
      child: Column(
        children: [
          TransactionDetailRow(
            title: context.l10n.transactionDebtDueOn,
            content: switch (DateTime.tryParse(debt.dueDate)) {
              final dueDate? => formatedDate(dueDate),
              null => '-',
            },
          ),
          const SizedBox(height: 8),
          TransactionDetailRow(
            title: context.l10n.transactionDebtRemaining,
            content: NumberFormatUtils.formatCurrency(
              debt.remainingAmount,
              currencyCode: debt.currency,
            ),
          ),
          if (debt.repaidAmount > 0) ...[
            const SizedBox(height: 8),
            TransactionDetailRow(
              title: context.l10n.transactionDebtAlreadyPaid,
              content: NumberFormatUtils.formatCurrency(
                debt.repaidAmount,
                currencyCode: debt.currency,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _resolvePartyName(
    String partyId, {
    required FriendsModel fallback,
    required Set<String> currentUserIds,
  }) {
    if (currentUserIds.contains(partyId)) {
      return fallback.username;
    }

    return transaction.friends
        .firstWhere(
          (friend) => friend.sid == partyId || friend.uid == partyId,
          orElse: () => fallback,
        )
        .username;
  }
}
