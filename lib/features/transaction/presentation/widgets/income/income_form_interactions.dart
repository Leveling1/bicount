part of '../income_form.dart';

extension _IncomeFormInteractions on _IncomeFormState {
  // ignore: unused_element
  void onCurrentUserChanged(bool? checked) {
    _update(() {
      if (checked == true) {
        _sender.text = context.l10n.commonMe;
      } else {
        _sender.clear();
      }
    });
  }

  // ignore: unused_element
  void _onSplitModeChanged(TransactionSplitMode mode) {
    _update(() {
      _splitMode = mode;
      if (mode != TransactionSplitMode.equal) {
        _seedSplitInputsForCurrentMode(overwrite: false);
      }
    });
  }

  // ignore: unused_element
  void _resetSplitInputs() {
    _update(() {
      _seedSplitInputsForCurrentMode(overwrite: true);
    });
  }

  // ignore: unused_element
  void _onSplitValueChanged(String _) {
    _update(() {});
  }

  void _addBeneficiary() {
    final rawValue = _beneficiary.text.trim();
    if (rawValue.isEmpty) {
      return;
    }

    if (_isEditing && _beneficiaryList.isNotEmpty) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionEditSingleBeneficiaryOnly,
      );
      return;
    }

    final beneficiary = _resolveParty(rawValue);
    final beneficiaryKey = _beneficiaryKey(beneficiary);
    final exists = _beneficiaryList.any(
      (friend) => _beneficiaryKey(friend) == beneficiaryKey,
    );
    if (exists) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.transactionDuplicateBeneficiary,
      );
      return;
    }

    _update(() {
      _beneficiaryList.add(beneficiary);
      _beneficiary.clear();
      _splitControllerFor(beneficiary);
      if (_splitMode != TransactionSplitMode.equal) {
        _seedSplitInputsForCurrentMode(overwrite: false);
      }
    });
  }

  void clearForm() {
    _update(() {
      _name.clear();
      _date.clear();
      _amount.clear();
      _currency.clear();
      _beneficiary.clear();
      _sender.clear();
      _note.clear();
      _beneficiaryList.clear();
      _splitMode = TransactionSplitMode.equal;
      for (final controller in _splitControllers.values) {
        controller.dispose();
      }
      _splitControllers.clear();
    });
  }
}
