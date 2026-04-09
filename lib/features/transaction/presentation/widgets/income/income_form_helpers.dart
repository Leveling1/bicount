part of '../income_form.dart';

extension _IncomeFormHelpers on _IncomeFormState {
  FriendsModel _resolveSender() {
    return _resolveParty(_sender.text.trim());
  }

  FriendsModel _resolveBeneficiary() {
    final user = widget.user;
    if (user == null) {
      throw MessageFailure(message: 'Authentication failure');
    }
    return _toCurrentUserParty();
  }

  FriendsModel _resolveParty(String rawValue) {
    if (_isCurrentUserAlias(rawValue) && widget.user != null) {
      return _toCurrentUserParty();
    }

    return widget.friends.firstWhere(
      (friend) => friend.username.toLowerCase() == rawValue.toLowerCase(),
      orElse: () => FriendsModel(
        sid: '',
        username: rawValue,
        uid: '',
        image: Constants.memojiDefault,
        email: '',
        relationType: FriendConst.friend,
      ),
    );
  }

  FriendsModel _toCurrentUserParty() {
    final user = widget.user!;
    return FriendsModel(
      sid: user.uid,
      username: user.username,
      uid: user.uid,
      image: user.image,
      email: user.email,
      relationType: FriendConst.friend,
    );
  }

  bool _isCurrentUser(FriendsModel party) {
    final user = widget.user;
    if (user == null) {
      return false;
    }

    return party.sid == user.uid || party.uid == user.uid;
  }

  TextEditingController _splitControllerFor(FriendsModel friend) {
    final key = _beneficiaryKey(friend);
    return _splitControllers.putIfAbsent(key, TextEditingController.new);
  }

  double? _parseAmount(String rawValue) {
    if (rawValue.trim().isEmpty) {
      return null;
    }
    return double.tryParse(rawValue.replaceAll(',', '.'));
  }

  String _resolveTransactionDate() {
    return resolveFormDateToIso(_date.text);
  }

  bool _isCurrentUserAlias(String rawValue) {
    final value = rawValue.trim().toLowerCase();
    if (value.isEmpty) {
      return false;
    }

    return <String>{
      'me',
      'moi',
      context.l10n.commonMe.toLowerCase(),
    }.contains(value);
  }

  String _beneficiaryKey(FriendsModel friend) {
    if (friend.sid.isNotEmpty) {
      return friend.sid;
    }
    return '${friend.username.toLowerCase()}::${friend.email.toLowerCase()}';
  }

  String get _selectedCurrency => _currency.text.isEmpty
      ? context.read<CurrencyCubit>().state.config.referenceCurrencyCode
      : _currency.text;
}
