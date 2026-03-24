part of 'transfer_form.dart';

extension _TransferFormInteractions on _TransferFormState {
  void _onCurrentUserChanged(bool? checked) {
    _update(() {
      if (checked == true) {
        _sender.text = context.l10n.commonMe;
      } else {
        _sender.clear();
      }
    });
  }

  void _onSplitModeChanged(TransactionSplitMode mode) {
    _update(() {
      _splitMode = mode;
      if (mode != TransactionSplitMode.equal) {
        _seedSplitInputsForCurrentMode(overwrite: false);
      }
    });
  }

  void _resetSplitInputs() {
    _update(() {
      _seedSplitInputsForCurrentMode(overwrite: true);
    });
  }

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

  void _removeBeneficiary(int index) {
    _update(() {
      final removed = _beneficiaryList.removeAt(index);
      final key = _beneficiaryKey(removed);
      _splitControllers.remove(key)?.dispose();
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
