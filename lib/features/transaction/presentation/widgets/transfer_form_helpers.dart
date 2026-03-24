part of 'transfer_form.dart';

extension _TransferFormHelpers on _TransferFormState {
  FriendsModel _resolveSender() {
    if (_sender.text.trim().isEmpty && widget.user != null) {
      return _toCurrentUserParty();
    }
    return _resolveParty(_sender.text.trim());
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
    if (_date.text.isEmpty) {
      return DateTime.now().toIso8601String();
    }

    final parsedDate =
        DateTime.tryParse(_date.text) ??
        DateFormat('dd/MM/yy').tryParseStrict(_date.text) ??
        DateFormat('dd/MM/yyyy').tryParseStrict(_date.text);
    if (parsedDate != null) {
      return parsedDate.toIso8601String();
    }

    return DateTime.now().toIso8601String();
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

  String get _selectedCurrency =>
      _currency.text.isEmpty ? 'USD' : _currency.text;
}
