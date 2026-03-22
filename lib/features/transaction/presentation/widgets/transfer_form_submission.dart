part of 'transfer_form.dart';

extension _TransferFormSubmission on _TransferFormState {
  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (state is TransactionCreated) {
      NotificationHelper.showSuccessNotification(
        context,
        context.l10n.transactionSavedSuccess,
      );
      clearForm();
      return;
    }

    if (state is TransactionError) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.failure.message),
      );
    }
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
        splitMode: _splitMode,
        splits: _buildSplitInputs(),
      );
      _splitResolver.resolve(request);
      context.read<TransactionBloc>().add(CreateTransactionEvent(request));
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
