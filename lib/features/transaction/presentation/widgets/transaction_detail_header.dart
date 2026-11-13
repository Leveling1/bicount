part of 'transaction_detail_content.dart';

extension on TransactionDetailContent {
  List<Widget> _heading(
    BuildContext context,
    TransactionDirection direction,
    TransactionEntity data,
    double iconSize,
  ) => [
    if (direction.isExternal || canManage)
      Row(
        children: [
          if (direction.isExternal)
            CustomBadge(
              text: context.l10n.transactionDetailExternalBadge,
              color: Theme.of(context).colorScheme.primary,
            ),
          const Spacer(),
          if (canManage)
            TransactionDetailActions(
              iconSize: iconSize,
              isLoading: isLoading,
              onDeletePressed: onDeletePressed,
              onEditPressed: onEditPressed,
            ),
        ],
      ),
    CircleAvatar(
      backgroundColor: Theme.of(context).cardColor,
      radius: 40,
      child: SizedBox(
        width: 50,
        height: 50,
        child: data.type == TransactionTypes.subscriptionCode
            ? Icon(Icons.subscriptions, color: Theme.of(context).primaryColor)
            : data.image?.isNotEmpty == true
            ? AppAvatar(image: data.image!, radius: 40)
            : Icon(
                Icons.payments_outlined,
                color: Theme.of(context).primaryColor,
              ),
      ),
    ),
    const SizedBox(height: 12),
  ];
}
