import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:flutter/material.dart';

class TransferFormBeneficiaryList extends StatelessWidget {
  const TransferFormBeneficiaryList({
    super.key,
    required this.beneficiaries,
    required this.sharesByKey,
    required this.currency,
    required this.beneficiaryKeyOf,
    required this.onRemove,
  });

  final List<FriendsModel> beneficiaries;
  final Map<String, ResolvedTransactionSplitEntity> sharesByKey;
  final String currency;
  final String Function(FriendsModel friend) beneficiaryKeyOf;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: beneficiaries.asMap().entries.map((entry) {
        final friend = entry.value;
        final previewShare = sharesByKey[beneficiaryKeyOf(friend)];
        return SizedBox(
          width: double.infinity,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              friend.username,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: previewShare == null
                ? null
                : Text(
                    '${context.l10n.commonPreview}: ${previewShare.amount.toStringAsFixed(2)} $currency',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => onRemove(entry.key),
            ),
          ),
        );
      }).toList(),
    );
  }
}
