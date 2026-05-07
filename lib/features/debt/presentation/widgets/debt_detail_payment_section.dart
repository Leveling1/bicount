import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebtDetailPaymentSection extends StatelessWidget {
  const DebtDetailPaymentSection({
    super.key,
    required this.amountController,
    required this.currencyController,
    required this.amountFieldLabel,
    required this.amountFieldHint,
    required this.invalidAmountMessage,
    required this.hintText,
    required this.recordPaymentLabel,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController amountController;
  final TextEditingController currencyController;
  final String amountFieldLabel;
  final String amountFieldHint;
  final String invalidAmountMessage;
  final String hintText;
  final String recordPaymentLabel;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(amountFieldLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.spacingSmall),
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,\. ]')),
          ],
          validator: (value) {
            final amount = double.tryParse(
              (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
            );
            if (amount == null || amount <= 0) {
              return invalidAmountMessage;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: CurrencyField(
              controller: currencyController,
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingSmall),
        Text(amountFieldHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppDimens.spacingLarge),
        CustomButton(
          text: recordPaymentLabel,
          loading: isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
