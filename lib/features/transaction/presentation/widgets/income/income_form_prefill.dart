part of '../income_form.dart';

extension _IncomeFormPrefill on _IncomeFormState {
  bool get _isEditing => widget.initialTransaction != null;

  void _prefillInitialTransactionIfNeeded() {
    if (_didPrefillInitialTransaction) {
      return;
    }

    final transaction = widget.initialTransaction;
    if (transaction == null) {
      _didPrefillInitialTransaction = true;
      return;
    }

    _didPrefillInitialTransaction = true;
    _name.text = transaction.name;
    _date.text = DateFormat('dd/MM/yyyy').format(transaction.date);
    _amount.text = _formatInitialAmount(transaction.amount);
    _currency.text = transaction.currency;
    _note.text = transaction.note;
    _sender.text = _partyLabelForId(transaction.sender);

    if (widget.user != null) {
      _beneficiaryList
        ..clear()
        ..add(toCurrentUserParty());
      return;
    }

    final beneficiary = _findPartyById(transaction.beneficiary);
    _beneficiaryList
      ..clear()
      ..add(beneficiary);
  }

  FriendsModel _findPartyById(String partyId) {
    if (widget.user != null && widget.user!.uid == partyId) {
      return toCurrentUserParty();
    }

    return widget.friends.firstWhere(
      (friend) => friend.sid == partyId || friend.uid == partyId,
      orElse: () => FriendsModel(
        sid: partyId,
        uid: '',
        username: partyId,
        image: Constants.memojiDefault,
        email: '',
        relationType: FriendConst.friend,
      ),
    );
  }

  String _partyLabelForId(String partyId) {
    if (widget.user != null && widget.user!.uid == partyId) {
      return context.l10n.commonMe;
    }

    return _findPartyById(partyId).username;
  }

  String _formatInitialAmount(double amount) {
    final isWholeNumber = amount == amount.truncateToDouble();
    return isWholeNumber ? amount.toStringAsFixed(0) : amount.toString();
  }
}
