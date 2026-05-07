part of '../income_form.dart';

extension _IncomeFormSubmission on _IncomeFormState {
  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (state is TransactionCreated) {
      final successMessage = _isRecurring
          ? context.l10n.accountFundingRecurringSavedSuccess
          : context.l10n.transactionSavedSuccess;
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(context, successMessage);
        clearForm();
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

    final totalAmount = parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionEnterValidAmount,
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
      final sender = _resolveSender();
      if (_isCurrentUser(sender)) {
        NotificationHelper.showFailureNotification(
          context,
          context.l10n.transactionIncomeSenderCannotBeCurrentUser,
        );
        return;
      }

      final request = CreateTransactionRequestEntity(
        name: _name.text.trim(),
        date: resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: selectedCurrency,
        sender: sender,
        note: _note.text.trim(),
        transactionType: transactionFormType,
        splitMode: TransactionSplitMode.equal,
        splits: _buildSplitInputs(),
        isRecurring: _isRecurring && !_isDebt,
        recurringFrequency: _isRecurring && !_isDebt
            ? _recurringFrequency
            : null,
        recurringTypeId: _isRecurring && !_isDebt ? _recurringTypeId : null,
        recurringExecutionMode:
            _isRecurring &&
                !_isDebt &&
                _recurringTypeId == TransactionTypes.salaryCode
            ? _recurringExecutionMode
            : null,
        recurringReminderEnabled:
            _isRecurring &&
                !_isDebt &&
                _recurringTypeId == TransactionTypes.salaryCode
            ? _recurringReminderEnabled
            : null,
        isDebt: _isDebt,
        debtDueDate: _isDebt ? resolveFormDateToIso(_debtDueDate.text) : null,
        debtExpectedRepaymentAmount: _isDebt ? expectedRepaymentAmount : null,
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
    return [TransactionSplitInputEntity(beneficiary: _resolveBeneficiary())];
  }
}
