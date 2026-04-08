import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
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
    required this.splitMode,
    required this.onSplitModeChanged,
    required this.splitControllerFor,
    required this.onSplitValueChanged,
    this.errorMessage,
  });

  final List<FriendsModel> beneficiaries;
  final Map<String, ResolvedTransactionSplitEntity> sharesByKey;
  final String currency;
  final String Function(FriendsModel friend) beneficiaryKeyOf;
  final ValueChanged<int> onRemove;
  final TransactionSplitMode splitMode;
  final ValueChanged<TransactionSplitMode> onSplitModeChanged;
  final TextEditingController Function(FriendsModel friend) splitControllerFor;
  final ValueChanged<String> onSplitValueChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final showSplitMode = beneficiaries.length > 1;
    final showSplitInput =
        showSplitMode && splitMode != TransactionSplitMode.equal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSplitMode) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransactionSplitMode.values.map((mode) {
              return ChoiceChip(
                backgroundColor: Theme.of(context).cardColor,
                disabledColor: Theme.of(context).cardColor,
                label: Text(context.splitModeLabel(mode)),
                selected: splitMode == mode,
                onSelected: (_) => onSplitModeChanged(mode),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              localizeRuntimeMessage(context, errorMessage!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
        ...beneficiaries.asMap().entries.map((entry) {
          final friend = entry.value;
          final previewShare = sharesByKey[beneficiaryKeyOf(friend)];
          final controller = splitControllerFor(friend);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BeneficiaryLineItem(
              friend: friend,
              previewShare: previewShare,
              currency: currency,
              showSplitInput: showSplitInput,
              splitMode: splitMode,
              controller: controller,
              onChanged: onSplitValueChanged,
              onRemove: () => onRemove(entry.key),
            ),
          );
        }),
      ],
    );
  }
}

class _BeneficiaryLineItem extends StatelessWidget {
  const _BeneficiaryLineItem({
    required this.friend,
    required this.previewShare,
    required this.currency,
    required this.showSplitInput,
    required this.splitMode,
    required this.controller,
    required this.onChanged,
    required this.onRemove,
  });

  final FriendsModel friend;
  final ResolvedTransactionSplitEntity? previewShare;
  final String currency;
  final bool showSplitInput;
  final TransactionSplitMode splitMode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final suffix = splitMode == TransactionSplitMode.percentage
        ? '%'
        : currency;
    final previewAmount = previewShare == null
        ? null
        : '${previewShare!.amount.toStringAsFixed(2)} $currency';

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(top: showSplitInput ? 6 : 0),
              child: Text(
                friend.username,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (showSplitInput) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 30,
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [CurrencyAmountFormatter()],
                  textAlign: TextAlign.right,
                  cursorHeight: 16,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: suffix,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4,
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
          if (previewAmount != null) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.commonPreview,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    previewAmount,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppDimens.spacerWidthMini,
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
