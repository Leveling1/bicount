import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebtContractInfoLine extends StatelessWidget {
  const DebtContractInfoLine({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingSmall),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppDimens.spacingSmall),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class DebtContractAmountField extends StatelessWidget {
  const DebtContractAmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.validatorMessage,
    this.allowEmpty = false,
    this.currencyController,
  });

  final TextEditingController controller;
  final String label;
  final String validatorMessage;
  final bool allowEmpty;
  final TextEditingController? currencyController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,\. ]')),
          ],
          validator: (value) {
            if (allowEmpty && (value == null || value.trim().isEmpty)) {
              return null;
            }
            final amount = double.tryParse(
              (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
            );
            if (amount == null || amount <= 0) {
              return validatorMessage;
            }
            return null;
          },
          decoration: InputDecoration(
            suffixIcon: currencyController == null
                ? null
                : CurrencyField(
                    controller: currencyController!,
                    color: Theme.of(context).cardColor,
                  ),
          ),
        ),
      ],
    );
  }
}
