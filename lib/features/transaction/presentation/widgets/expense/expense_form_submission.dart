part of '../expense_form.dart';

extension _ExpenseFormSubmission on _ExpenseFormState {
  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (state is TransactionCreated) {
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(
          context,
          context.l10n.transactionSavedSuccess,
        );
        clearForm();
        Navigator.of(context).pop();
        widget.onCompleted?.call();
      });
      return;
    }

    if (state is TransactionUpdated) {
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(
          context,
          context.l10n.transactionUpdatedSuccess,
        );
        widget.onCompleted?.call();
      });
      return;
    }

    if (state is TransactionError) {
      _runAfterFrame(() {
        NotificationHelper.showFailureNotification(
          context,
          localizeRuntimeMessage(context, state.failure.message),
        );
      });
    }
  }

  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      action();
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_beneficiaryList.isEmpty && _beneficiary.text.trim().isNotEmpty) {
      _addBeneficiary();
    }
    if (_beneficiaryList.isEmpty) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionAddAtLeastOneBeneficiary,
      );
      return;
    }

    if (_isEditing && _beneficiaryList.length != 1) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionEditSingleBeneficiaryOnly,
      );
      return;
    }

    final totalAmount = parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionEnterValidAmount,
      );
      return;
    }

    if (_isDebt && _beneficiaryList.length != 1) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionDebtSingleBeneficiaryOnly,
      );
      return;
    }

    final expectedRepaymentAmount = parseAmount(
      _debtExpectedRepaymentAmount.text,
    );
    if (_isDebt &&
        _debtExpectedRepaymentAmount.text.trim().isNotEmpty &&
        (expectedRepaymentAmount == null || expectedRepaymentAmount <= 0)) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionDebtExpectedAmountInvalid,
      );
      return;
    }

    try {
      final request = CreateTransactionRequestEntity(
        name: _name.text.trim(),
        date: resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: selectedCurrency,
        sender: _resolveSender(),
        note: _note.text.trim(),
        transactionType: transactionFormType,
        splitMode: _isEditing ? TransactionSplitMode.equal : _splitMode,
        splits: _buildSplitInputs(),
        isRecurring: _isRecurring && !_isDebt,
        recurringFrequency: _isRecurring && !_isDebt
            ? _recurringFrequency
            : null,
        recurringTypeId: _isRecurring && !_isDebt ? _recurringTypeId : null,
        isDebt: _isDebt,
        debtDueDate: _isDebt ? resolveFormDateToIso(_debtDueDate.text) : null,
        debtExpectedRepaymentAmount: _isDebt ? expectedRepaymentAmount : null,
        debtExpectedRepaymentCurrency: _isDebt
            ? _debtExpectedRepaymentCurrency.text
            : null,
      );
      _splitResolver.resolve(request);
      if (_isEditing) {
        context.read<TransactionBloc>().add(
          UpdateTransactionEvent(widget.initialTransaction!, request),
        );
      } else {
        context.read<TransactionBloc>().add(CreateTransactionEvent(request));
      }
    } on MessageFailure catch (error) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, error.message),
      );
    }
  }

  List<TransactionSplitInputEntity> _buildSplitInputs() {
    return _beneficiaryList.map((friend) {
      final value = parseAmount(splitControllerFor(friend).text);
      return TransactionSplitInputEntity(
        beneficiary: friend,
        percentage: _splitMode == TransactionSplitMode.percentage
            ? value
            : null,
        amount: _splitMode == TransactionSplitMode.customAmount ? value : null,
      );
    }).toList();
  }
}
