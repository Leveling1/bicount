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

    final totalAmount = _parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionEnterValidAmount,
      );
      return;
    }

    try {
      final request = CreateTransactionRequestEntity(
        name: _name.text.trim(),
        date: _resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: _selectedCurrency,
        sender: _resolveSender(),
        note: _note.text.trim(),
        splitMode: _isEditing ? TransactionSplitMode.equal : _splitMode,
        splits: _buildSplitInputs(),
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
      final value = _parseAmount(_splitControllerFor(friend).text);
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
