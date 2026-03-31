import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';

class MainFinanceProjectionService {
  const MainFinanceProjectionService({
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final CurrencyAmountService currencyAmountService;

  MainEntity project({
    required UserModel user,
    required List<FriendsModel> friends,
    required List<SubscriptionModel> subscriptions,
    required List<TransactionModel> transactions,
    required List<AccountFundingModel> accountFundings,
    required List<RecurringFundingModel> recurringFundings,
    required int connectionState,
    required CurrencyConfigEntity currencyConfig,
  }) {
    return MainEntity(
      user: _deriveUser(user, transactions, accountFundings, currencyConfig),
      connectionState: connectionState,
      referenceCurrencyCode: currencyConfig.referenceCurrencyCode,
      monthlySubscriptionSpend: subscriptions.fold<double>(
        0,
        (sum, subscription) =>
            sum +
            currencyAmountService.monthlySubscription(
              subscription,
              currencyConfig,
            ),
      ),
      friends: _deriveFriends(
        currentUserId: user.uid,
        friends: friends,
        transactions: transactions,
        currencyConfig: currencyConfig,
      ),
      subscriptions: subscriptions,
      transactions: transactions,
      accountFundings: accountFundings,
      recurringFundings: recurringFundings,
    );
  }

  UserModel _deriveUser(
    UserModel user,
    List<TransactionModel> transactions,
    List<AccountFundingModel> accountFundings,
    CurrencyConfigEntity currencyConfig,
  ) {
    double balance = 0;
    double incomes = 0;
    double expenses = 0;
    double personalIncome = 0;
    double companyIncome = 0;

    for (final transaction in transactions) {
      final amount = currencyAmountService.transaction(
        transaction,
        currencyConfig,
      );
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
      final amount = currencyAmountService.funding(funding, currencyConfig);
      balance += amount;
      incomes += amount;
      personalIncome += amount;
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
      referenceCurrencyCode: user.referenceCurrencyCode,
    );
  }

  List<FriendsModel> _deriveFriends({
    required String currentUserId,
    required List<FriendsModel> friends,
    required List<TransactionModel> transactions,
    required CurrencyConfigEntity currencyConfig,
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
          amount: currencyAmountService.transaction(
            transaction,
            currencyConfig,
          ),
          category: category,
          isSender: true,
        );
      }

      if (transaction.beneficiaryId != currentUserId) {
        final beneficiary = aggregatesById[transaction.beneficiaryId];
        beneficiary?.apply(
          amount: currencyAmountService.transaction(
            transaction,
            currencyConfig,
          ),
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
