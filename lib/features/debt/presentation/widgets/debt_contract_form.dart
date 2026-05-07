import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_dimens.dart';

class DebtContractForm extends StatefulWidget {
  const DebtContractForm({
    super.key,
    required this.debt,
    required this.principalTransaction,
    required this.counterpartyName,
    required this.isLoading,
    required this.onSubmit,
    this.onCancel,
  });

  final DebtModel debt;
  final TransactionEntity principalTransaction;
  final String counterpartyName;
  final bool isLoading;
  final ValueChanged<UpdateDebtRequestEntity> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<DebtContractForm> createState() => _DebtContractFormState();
}

class _DebtContractFormState extends State<DebtContractForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _expectedAmountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.debt.title);
    _dateController = TextEditingController(
      text: formatDate(widget.principalTransaction.date),
    );
    _amountController = TextEditingController(
      text: widget.debt.principalAmount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _currencyController = TextEditingController(text: widget.debt.currency);
    _dueDateController = TextEditingController(
      text: formatDate(
        DateTime.tryParse(widget.debt.dueDate) ?? DateTime.now(),
      ),
    );
    _expectedAmountController = TextEditingController(
      text: widget.debt.expectedRepaymentAmount
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );
    _noteController = TextEditingController(text: widget.debt.note);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _dueDateController.dispose();
    _expectedAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.debtEditTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          _line(context.l10n.debtCounterpartyLabel, widget.counterpartyName),
          _line(
            context.l10n.debtRepaidLabel,
            '${widget.debt.repaidAmount.toStringAsFixed(2)} ${widget.debt.currency}',
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomFormField(
            controller: _titleController,
            label: context.l10n.debtTitleLabel,
            hint: context.l10n.transferEnterTransactionName,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomFormField(
            controller: _dateController,
            label: context.l10n.commonDate,
            hint: context.l10n.commonDateHint,
            isDate: true,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          _buildAmountField(
            context,
            controller: _amountController,
            label: context.l10n.commonAmount,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomFormField(
            controller: _dueDateController,
            label: context.l10n.transactionDebtDueDateLabel,
            hint: context.l10n.commonDateHint,
            isDate: true,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          _buildAmountField(
            context,
            controller: _expectedAmountController,
            label: context.l10n.transactionDebtExpectedAmountLabel,
            showCurrencyPicker: false,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomFormField(
            controller: _noteController,
            label: context.l10n.commonNote,
            hint: context.l10n.commonNote,
            enableValidator: false,
          ),
          const SizedBox(height: AppDimens.spacingLarge),
          CustomButton(
            text: context.l10n.commonSave,
            onPressed: _submit,
            loading: widget.isLoading,
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: AppDimens.spacingSmall),
            CustomOutlinedButton(
              text: context.l10n.commonCancel,
              onPressed: widget.onCancel!,
              loading: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    bool showCurrencyPicker = true,
  }) {
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
            final amount = _parseAmount(value);
            if (amount == null || amount <= 0) {
              return context.l10n.transactionEnterValidAmount;
            }
            return null;
          },
          decoration: InputDecoration(
            suffixIcon: showCurrencyPicker
                ? CurrencyField(
                    controller: _currencyController,
                    color: Theme.of(context).cardColor,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _line(String label, String value) {
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

  double? _parseAmount(String? value) {
    return double.tryParse(
      (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final principalAmount = _parseAmount(_amountController.text);
    final expectedAmount = _parseAmount(_expectedAmountController.text);
    if (principalAmount == null || expectedAmount == null) {
      return;
    }

    widget.onSubmit(
      UpdateDebtRequestEntity(
        debtId: widget.debt.debtId ?? '',
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        principalDate: resolveFormDateToIso(_dateController.text),
        principalAmount: principalAmount,
        currency: _currencyController.text.trim().toUpperCase(),
        dueDate: resolveFormDateToIso(_dueDateController.text),
        expectedRepaymentAmount: expectedAmount,
      ),
    );
  }
}
