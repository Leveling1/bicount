import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/presentation/widgets/split_preview_result.dart';
import 'package:flutter/material.dart';

class TransferFormPreviewCard extends StatelessWidget {
  const TransferFormPreviewCard({
    super.key,
    required this.preview,
    required this.splitMode,
    required this.currency,
  });

  final SplitPreviewResult preview;
  final TransactionSplitMode splitMode;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: preview.errorMessage != null
          ? Text(
              localizeRuntimeMessage(context, preview.errorMessage!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.commonPreview,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...preview.resolvedSplits.map((split) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            split.beneficiary.username,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (split.percentage != null &&
                            splitMode != TransactionSplitMode.customAmount)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              '${split.percentage!.toStringAsFixed(2)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        Text(
                          '${split.amount.toStringAsFixed(2)} $currency',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
