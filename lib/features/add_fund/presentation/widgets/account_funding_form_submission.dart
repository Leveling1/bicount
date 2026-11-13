part of 'account_funding_form.dart';

extension on _AccountFundingFormState {
  void _onStateChanged(BuildContext context, AddFundState state) {
    if (state is AddFundSaved) {
      NotificationHelper.showSuccessNotification(
        context,
        state.isRecurring
            ? context.l10n.accountFundingRecurringSavedSuccess
            : context.l10n.accountFundingSavedSuccess,
      );
      final onCompleted = widget.onCompleted;
      if (onCompleted != null) {
        onCompleted();
      } else {
        Navigator.pop(context);
      }
    } else if (state is AddFundFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isRecurring && _selectedFrequency == null) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.validationFieldRequired,
      );
      return;
    }
    final event = buildAddFundEvent(
      initialFunding: widget.initialFunding,
      walletId: _walletId,
      source: _source.text,
      amount: _amount.text,
      currency: _currency.text,
      note: _note.text,
      date: _date.text,
      fundingType: _selectedFundingType,
      isRecurring: _isRecurring,
      frequency: _selectedFrequency,
      salaryProcessingMode: _salaryProcessingMode,
      salaryReminderStatus: _salaryReminderStatus,
    );
    context.read<AddFundBloc>().add(event);
  }
}
