part of '../expense_form.dart';

extension _ExpenseFormHelpers on _ExpenseFormState {
  FriendsModel _resolveSender() {
    if (widget.user != null) {
      return toCurrentUserParty();
    }
    return resolveParty(_sender.text.trim());
  }
}
