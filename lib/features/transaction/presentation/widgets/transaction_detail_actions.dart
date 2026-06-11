import 'package:bicount/core/widgets/custom_button.dart';
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
          CustomIconButton(
            onPressed: onEditPressed,
            icon: Icons.edit,
            loading: isLoading,
          ),
        if (hasDelete)
          CustomIconButton(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            color: Theme.of(context).colorScheme.error,
            loading: isLoading,
          ),
      ],
    );
  }
}
