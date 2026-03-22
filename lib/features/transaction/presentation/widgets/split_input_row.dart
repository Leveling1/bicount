
import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/details_card.dart';
import '../../../main/data/models/friends.model.dart';
import '../../domain/entities/create_transaction_request_entity.dart';

class SplitInputRow extends StatelessWidget {
  final FriendsModel friend;
  final TextEditingController controller;
  final TransactionSplitMode mode;
  final String currency;
  final ValueChanged<String> onChanged;


  const SplitInputRow({
    super.key,
    required this.friend,
    required this.controller,
    required this.mode,
    required this.currency,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    final suffix = mode == TransactionSplitMode.percentage ? '%' : currency;

    return DetailsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  mode == TransactionSplitMode.percentage
                      ? context.l10n.transactionSetPercentageReceived
                      : context.l10n.transactionSetExactAmountReceived,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(suffixText: suffix, hintText: '0.00'),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}