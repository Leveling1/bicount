import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:flutter/material.dart';

class DebtDetailSheet extends StatefulWidget {
  const DebtDetailSheet({
    super.key,
    required this.summary,
    required this.titleText,
    required this.counterpartyLabel,
    required this.expectedLabel,
    required this.repaidLabel,
    required this.remainingLabel,
    required this.dueDateLabel,
    required this.amountFieldLabel,
    required this.amountFieldHint,
    required this.recordPaymentLabel,
    required this.permissionHint,
    required this.invalidAmountMessage,
    required this.isLoading,
    required this.onRecordPayment,
  });

  final DebtSummaryEntity summary;
  final String titleText;
  final String counterpartyLabel;
  final String expectedLabel;
  final String repaidLabel;
  final String remainingLabel;
  final String dueDateLabel;
  final String amountFieldLabel;
  final String amountFieldHint;
  final String recordPaymentLabel;
  final String permissionHint;
  final String invalidAmountMessage;
  final bool isLoading;
  final ValueChanged<double> onRecordPayment;

  @override
  State<DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends State<DebtDetailSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debt = widget.summary.debt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titleText, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimens.spacingMedium),
        _line(
          context,
          widget.counterpartyLabel,
          widget.summary.counterpartyName,
        ),
        _line(
          context,
          widget.expectedLabel,
          NumberFormatUtils.formatCurrency(
            debt.expectedRepaymentAmount,
            currencyCode: debt.currency,
          ),
        ),
        _line(
          context,
          widget.repaidLabel,
          NumberFormatUtils.formatCurrency(
            debt.repaidAmount,
            currencyCode: debt.currency,
          ),
        ),
        _line(
          context,
          widget.remainingLabel,
          NumberFormatUtils.formatCurrency(
            debt.remainingAmount,
            currencyCode: debt.currency,
          ),
        ),
        _line(
          context,
          widget.dueDateLabel,
          widget.summary.dueDate == null
              ? '-'
              : formatDate(widget.summary.dueDate!),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        if (widget.summary.canRecordPayment && debt.remainingAmount > 0) ...[
          CustomFormField(
            controller: _amountController,
            label: widget.amountFieldLabel,
            hint: widget.amountFieldHint,
            inputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppDimens.spacingLarge),
          CustomButton(
            text: widget.recordPaymentLabel,
            loading: widget.isLoading,
            onPressed: _submit,
          ),
        ] else ...[
          Text(
            widget.permissionHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: AppDimens.spacingLarge),
      ],
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: AppDimens.spacingSmall),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null ||
        amount <= 0 ||
        amount > widget.summary.debt.remainingAmount) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.invalidAmountMessage)));
      return;
    }

    widget.onRecordPayment(amount);
  }
}
