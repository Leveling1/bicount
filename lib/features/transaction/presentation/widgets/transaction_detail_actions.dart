import 'package:flutter/material.dart';

class TransactionDetailActions extends StatelessWidget {
  const TransactionDetailActions({
    super.key,
    required this.iconSize,
    required this.isLoading,
    this.onDeletePressed,
    this.onEditPressed,
  });

  final double iconSize;
  final bool isLoading;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final hasEdit = onEditPressed != null;
    final hasDelete = onDeletePressed != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasEdit)
          IconButton(
            onPressed: isLoading ? null : onEditPressed,
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).iconTheme.color,
              size: iconSize,
            ),
          ),
        if (hasDelete)
          IconButton(
            onPressed: isLoading ? null : onDeletePressed,
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
              size: iconSize,
            ),
          ),
      ],
    );
  }
}
