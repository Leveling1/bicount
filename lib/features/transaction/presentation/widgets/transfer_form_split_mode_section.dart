import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:flutter/material.dart';

class TransferFormSplitModeSection extends StatelessWidget {
  const TransferFormSplitModeSection({
    super.key,
    required this.splitMode,
    required this.onChanged,
  });

  final TransactionSplitMode splitMode;
  final ValueChanged<TransactionSplitMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transactionSplitMethod,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionSplitMode.values.map((mode) {
            return ChoiceChip(
              backgroundColor: Theme.of(context).cardColor,
              disabledColor: Theme.of(context).cardColor,
              label: Text(context.splitModeLabel(mode)),
              selected: splitMode == mode,
              onSelected: (_) => onChanged(mode),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
