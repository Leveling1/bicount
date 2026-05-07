import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onEditPressed,
    this.onDeletePressed,
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
  final void Function(double amount, String currency) onRecordPayment;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  State<DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends State<DebtDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _currencyController;

  @override
  void initState() {
    super.initState();
    _currencyController = TextEditingController(
      text: widget.summary.debt.currency,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debt = widget.summary.debt;

    return Form(
      key: _formKey,
      child: Column(
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
            Text(
              widget.amountFieldLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,\. ]')),
              ],
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
                );
                if (amount == null || amount <= 0) {
                  return widget.invalidAmountMessage;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: debt.remainingAmount
                    .toStringAsFixed(2)
                    .replaceAll('.', ','),
                suffixIcon: CurrencyField(
                  controller: _currencyController,
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            Text(
              widget.amountFieldHint,
              style: Theme.of(context).textTheme.bodySmall,
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
          if (widget.onEditPressed != null ||
              widget.onDeletePressed != null) ...[
            const SizedBox(height: AppDimens.spacingMedium),
            if (widget.onEditPressed != null) ...[
              CustomOutlinedButton(
                text: context.l10n.debtEditAction,
                onPressed: widget.onEditPressed!,
                loading: false,
              ),
              const SizedBox(height: AppDimens.spacingSmall),
            ],
            if (widget.onDeletePressed != null)
              TextButton(
                onPressed: widget.isLoading ? null : widget.onDeletePressed,
                child: Text(context.l10n.debtDeleteAction),
              ),
          ],
          const SizedBox(height: AppDimens.spacingLarge),
        ],
      ),
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(' ', '').replaceAll(',', '.'),
    );
    final currency = _currencyController.text.trim().toUpperCase();
    if (amount == null || amount <= 0 || currency.isEmpty) {
      return;
    }

    widget.onRecordPayment(amount, currency);
  }
}
