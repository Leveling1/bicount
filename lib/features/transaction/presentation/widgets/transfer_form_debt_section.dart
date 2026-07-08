import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:flutter/material.dart';

class TransferFormDebtSection extends StatelessWidget {
  const TransferFormDebtSection({
    super.key,
    required this.isDebt,
    required this.subtitle,
    required this.enabled,
    required this.dueDateController,
    required this.expectedAmountController,
    required this.expectedCurrencyController,
    required this.onDebtChanged,
  });

  final bool isDebt;
  final String subtitle;
  final bool enabled;
  final TextEditingController dueDateController;
  final TextEditingController expectedAmountController;
  final TextEditingController expectedCurrencyController;
  final ValueChanged<bool> onDebtChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: isDebt,
          onChanged: enabled ? onDebtChanged : null,
          title: Text(
            context.l10n.transactionDebtToggleTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isDebt
              ? Padding(
                  padding: const EdgeInsets.only(top: AppDimens.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        controller: dueDateController,
                        label: context.l10n.transactionDebtDueDateLabel,
                        hint: context.l10n.commonDateHint,
                        isDate: true,
                      ),
                      const SizedBox(height: AppDimens.spacingMedium),
                      SimpleAmountField(
                        enableValidator: false,
                        label: context.l10n.transactionDebtExpectedAmountLabel,
                        amount: expectedAmountController,
                        currency: expectedCurrencyController,
                        hintText:
                            context.l10n.transactionDebtExpectedAmountHint,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
