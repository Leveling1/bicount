import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_contract_form_fields.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_dimens.dart';

part 'debt_contract_form_submission.dart';

part 'debt_contract_form_submit_action.dart';

class DebtContractForm extends StatefulWidget {
  const DebtContractForm({
    super.key,
    required this.debt,
    required this.isLender,
    required this.principalTransaction,
    required this.counterpartyName,
    required this.isLoading,
    required this.onSubmit,
    this.onCancel,
  });

  final DebtModel debt;
  final bool isLender;
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
  bool _syncExpectedToPrincipal = false;
  bool _isPatchingExpectedAmount = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.debt.title);
    _dateController = TextEditingController(
      text: formatedDateTimeNumericFullYear(widget.principalTransaction.date),
    );
    _amountController = TextEditingController(
      text: widget.debt.principalAmount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _currencyController = TextEditingController(text: widget.debt.currency);
    _dueDateController = TextEditingController(
      text: formatedDateTimeNumericFullYear(
        DateTime.tryParse(widget.debt.dueDate) ?? DateTime.now(),
      ),
    );
    _expectedAmountController = TextEditingController(
      text: widget.debt.expectedRepaymentAmount
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );
    _noteController = TextEditingController(text: widget.debt.note);
    _syncExpectedToPrincipal =
        _parseAmount(_amountController.text) ==
        _parseAmount(_expectedAmountController.text);
    _amountController.addListener(_syncExpectedAmountFromPrincipal);
    _expectedAmountController.addListener(_trackExpectedAmountMode);
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
          DebtContractInfoLine(
            label: context.l10n.debtCounterpartyLabel,
            value: widget.counterpartyName,
          ),
          DebtContractInfoLine(
            label: context.l10n.debtRepaidLabel,
            value:
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
          DebtContractAmountField(
            controller: _amountController,
            label: context.l10n.commonAmount,
            validatorMessage: context.l10n.transactionEnterValidAmount,
            currencyController: _currencyController,
          ),
          WalletPicker(
            label: widget.isLender
                ? context.l10n.walletFrom
                : context.l10n.walletTo,
            value:
                _walletId ??
                (widget.isLender
                    ? widget.debt.lenderWalletId
                    : widget.debt.borrowerWalletId),
            onChanged: (id) => setState(() => _walletId = id),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomFormField(
            controller: _dueDateController,
            label: context.l10n.transactionDebtDueDateLabel,
            hint: context.l10n.commonDateHint,
            isDate: true,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          DebtContractAmountField(
            controller: _expectedAmountController,
            label: context.l10n.transactionDebtExpectedAmountLabel,
            validatorMessage: context.l10n.transactionEnterValidAmount,
            allowEmpty: true,
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
          AppDimens.spacerMedium,
        ],
      ),
    );
  }

  String? _walletId;
}
