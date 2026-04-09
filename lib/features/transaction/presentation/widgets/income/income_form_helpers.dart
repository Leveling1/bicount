part of '../income_form.dart';

extension _IncomeFormHelpers on _IncomeFormState {
  FriendsModel _resolveSender() {
    return resolveParty(_sender.text.trim());
  }

  FriendsModel _resolveBeneficiary() {
    final user = widget.user;
    if (user == null) {
      throw MessageFailure(message: 'Authentication failure');
    }
    return toCurrentUserParty();
  }

  bool _isCurrentUser(FriendsModel party) {
    final user = widget.user;
    if (user == null) {
      return false;
    }

    return party.sid == user.uid || party.uid == user.uid;
  }
}
