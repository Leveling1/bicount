import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_detail_meta_line.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_detail_payment_section.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_actions.dart';
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
          TransactionDetailActions(
            iconSize: 20,
            isLoading: widget.isLoading,
            onDeletePressed: widget.onDeletePressed,
            onEditPressed: widget.onEditPressed,
          ),
          Text(widget.titleText, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimens.spacingMedium),
          DebtDetailMetaLine(
            label: widget.counterpartyLabel,
            value: widget.summary.counterpartyName,
          ),
          DebtDetailMetaLine(
            label: widget.expectedLabel,
            value: NumberFormatUtils.formatCurrency(
              debt.expectedRepaymentAmount,
              currencyCode: debt.currency,
            ),
          ),
          DebtDetailMetaLine(
            label: widget.repaidLabel,
            value: NumberFormatUtils.formatCurrency(
              debt.repaidAmount,
              currencyCode: debt.currency,
            ),
          ),
          DebtDetailMetaLine(
            label: widget.remainingLabel,
            value: NumberFormatUtils.formatCurrency(
              debt.remainingAmount,
              currencyCode: debt.currency,
            ),
          ),
          DebtDetailMetaLine(
            label: widget.dueDateLabel,
            value: widget.summary.dueDate == null
                ? '-'
                : formatDate(widget.summary.dueDate!),
          ),
          const SizedBox(height: AppDimens.spacingLarge),
          if (widget.summary.canRecordPayment && debt.remainingAmount > 0) ...[
            DebtDetailPaymentSection(
              amountController: _amountController,
              currencyController: _currencyController,
              amountFieldLabel: widget.amountFieldLabel,
              amountFieldHint: widget.amountFieldHint,
              invalidAmountMessage: widget.invalidAmountMessage,
              hintText: debt.remainingAmount
                  .toStringAsFixed(2)
                  .replaceAll('.', ','),
              recordPaymentLabel: widget.recordPaymentLabel,
              isLoading: widget.isLoading,
              onSubmit: _submit,
            ),
          ] else ...[
            Text(
              widget.permissionHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppDimens.spacingLarge),
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
