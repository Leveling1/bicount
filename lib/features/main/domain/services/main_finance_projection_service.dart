import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';

class MainFinanceProjectionService {
  const MainFinanceProjectionService();

  MainEntity project({
    required UserModel user,
    required List<FriendsModel> friends,
    required List<SubscriptionModel> subscriptions,
    required List<TransactionModel> transactions,
    required List<AccountFundingModel> accountFundings,
    required int connectionState,
  }) {
    return MainEntity(
      user: _deriveUser(user, transactions, accountFundings),
      connectionState: connectionState,
      friends: _deriveFriends(
        currentUserId: user.uid,
        friends: friends,
        transactions: transactions,
      ),
      subscriptions: subscriptions,
      transactions: transactions,
      accountFundings: accountFundings,
    );
  }

  UserModel _deriveUser(
    UserModel user,
    List<TransactionModel> transactions,
    List<AccountFundingModel> accountFundings,
  ) {
    double balance = 0;
    double incomes = 0;
    double expenses = 0;
    double personalIncome = 0;
    double companyIncome = 0;

    for (final transaction in transactions) {
      final amount = transaction.amount;
      final category = transaction.category ?? Constants.personal;

      if (transaction.senderId == user.uid) {
        balance -= amount;
        expenses += amount;
        if (category == Constants.personal) {
          personalIncome -= amount;
        } else if (category == Constants.company) {
          companyIncome -= amount;
        }
      }

      if (transaction.beneficiaryId == user.uid) {
        balance += amount;
        incomes += amount;
        if (category == Constants.personal) {
          personalIncome += amount;
        } else if (category == Constants.company) {
          companyIncome += amount;
        }
      }
    }

    for (final funding in accountFundings) {
      if (funding.sid != user.uid || funding.category != Constants.personal) {
        continue;
      }
      balance += funding.amount;
      incomes += funding.amount;
      personalIncome += funding.amount;
    }

    return UserModel(
      uid: user.uid,
      image: user.image,
      username: user.username,
      email: user.email,
      balance: balance,
      incomes: incomes,
      expenses: expenses,
      companyIncome: companyIncome,
      personalIncome: personalIncome,
    );
  }

  List<FriendsModel> _deriveFriends({
    required String currentUserId,
    required List<FriendsModel> friends,
    required List<TransactionModel> transactions,
  }) {
    final aggregatesById = <String, _FriendAggregate>{};

    for (final friend in friends) {
      final aggregate = _FriendAggregate(friend);
      aggregatesById[friend.sid] = aggregate;
      final linkedUid = friend.uid;
      if (linkedUid != null && linkedUid.isNotEmpty) {
        aggregatesById[linkedUid] = aggregate;
      }
    }

    for (final transaction in transactions) {
      final category = transaction.category ?? Constants.personal;

      if (transaction.senderId != currentUserId) {
        final sender = aggregatesById[transaction.senderId];
        sender?.apply(
          amount: transaction.amount,
          category: category,
          isSender: true,
        );
      }

      if (transaction.beneficiaryId != currentUserId) {
        final beneficiary = aggregatesById[transaction.beneficiaryId];
        beneficiary?.apply(
          amount: transaction.amount,
          category: category,
          isSender: false,
        );
      }
    }

    return friends
        .map((friend) => aggregatesById[friend.sid]!.toModel())
        .toList();
  }
}

class _FriendAggregate {
  _FriendAggregate(this._friend);

  final FriendsModel _friend;
  double give = 0;
  double receive = 0;
  double personalIncome = 0;
  double companyIncome = 0;

  void apply({
    required double amount,
    required int category,
    required bool isSender,
  }) {
    if (isSender) {
      give += amount;
    } else {
      receive += amount;
    }

    if (category == Constants.personal) {
      personalIncome += isSender ? -amount : amount;
    } else if (category == Constants.company) {
      companyIncome += isSender ? -amount : amount;
    }
  }

  FriendsModel toModel() {
    return FriendsModel(
      sid: _friend.sid,
      uid: _friend.uid,
      fid: _friend.fid,
      image: _friend.image,
      username: _friend.username,
      email: _friend.email,
      give: give,
      receive: receive,
      relationType: _friend.relationType,
      personalIncome: personalIncome,
      companyIncome: companyIncome,
    );
  }
}
