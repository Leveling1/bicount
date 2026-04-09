import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin TransactionFormHelpers<T extends StatefulWidget> on State<T> {
  UserModel? get transactionFormUser;
  int get transactionFormType;
  List<FriendsModel> get transactionFormFriends;
  TextEditingController get transactionDateController;
  TextEditingController get transactionCurrencyController;
  Map<String, TextEditingController> get transactionSplitControllers;

  FriendsModel resolveParty(String rawValue) {
    if (isCurrentUserAlias(rawValue) && transactionFormUser != null) {
      return toCurrentUserParty();
    }

    return transactionFormFriends.firstWhere(
      (friend) => friend.username.toLowerCase() == rawValue.toLowerCase(),
      orElse: () => FriendsModel(
        sid: '',
        username: rawValue,
        uid: '',
        image: Constants.memojiDefault,
        email: '',
        relationType: FriendConst.getTypeOfFriend(transactionFormType),
      ),
    );
  }

  FriendsModel toCurrentUserParty() {
    final user = transactionFormUser!;
    return FriendsModel(
      sid: user.uid,
      username: user.username,
      uid: user.uid,
      image: user.image,
      email: user.email,
      relationType: FriendConst.friend,
    );
  }

  TextEditingController splitControllerFor(FriendsModel friend) {
    final key = beneficiaryKey(friend);
    return transactionSplitControllers.putIfAbsent(
      key,
      TextEditingController.new,
    );
  }

  double? parseAmount(String rawValue) {
    if (rawValue.trim().isEmpty) {
      return null;
    }
    return double.tryParse(rawValue.replaceAll(',', '.'));
  }

  String resolveTransactionDate() {
    return resolveFormDateToIso(transactionDateController.text);
  }

  bool isCurrentUserAlias(String rawValue) {
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

  String beneficiaryKey(FriendsModel friend) {
    if (friend.sid.isNotEmpty) {
      return friend.sid;
    }
    return '${friend.username.toLowerCase()}::${friend.email.toLowerCase()}';
  }

  String get selectedCurrency => transactionCurrencyController.text.isEmpty
      ? context.read<CurrencyCubit>().state.config.referenceCurrencyCode
      : transactionCurrencyController.text;
}
