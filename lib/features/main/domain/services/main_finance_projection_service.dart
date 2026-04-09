import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class MainFinanceProjectionService {
  const MainFinanceProjectionService({
    this.currencyAmountService = const CurrencyAmountService(),
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService participantIdentityService;

  MainEntity project({
    required UserModel user,
    required List<FriendsModel> friends,
    required List<TransactionModel> transactions,
    required List<RecurringTransfertModel> recurringTransferts,
    required int connectionState,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final relevantTransactions = participantIdentityService
        .filterTransactionsForCurrentUser(
          currentUserId: user.uid,
          friends: friends,
          transactions: transactions,
        );
    final currentUserParticipantIds = participantIdentityService
        .currentUserParticipantIds(currentUserId: user.uid, friends: friends);

    return MainEntity(
      user: _deriveUser(
        user,
        relevantTransactions,
        currencyConfig,
        currentUserParticipantIds,
      ),
      connectionState: connectionState,
      referenceCurrencyCode: currencyConfig.referenceCurrencyCode,
      friends: _deriveFriends(
        currentUserParticipantIds: currentUserParticipantIds,
        friends: friends,
        transactions: relevantTransactions,
        currencyConfig: currencyConfig,
      ),
      transactions: relevantTransactions,
      recurringTransferts: recurringTransferts,
    );
  }

  UserModel _deriveUser(
    UserModel user,
    List<TransactionModel> transactions,
    CurrencyConfigEntity currencyConfig,
    Set<String> currentUserParticipantIds,
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

      if (currentUserParticipantIds.contains(transaction.senderId)) {
        balance -= amount;
        expenses += amount;
        if (category == Constants.personal) {
          personalIncome -= amount;
        } else if (category == Constants.company) {
          companyIncome -= amount;
        }
      }

      if (currentUserParticipantIds.contains(transaction.beneficiaryId)) {
        balance += amount;
        incomes += amount;
        if (category == Constants.personal) {
          personalIncome += amount;
        } else if (category == Constants.company) {
          companyIncome += amount;
        }
      }
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
    required Set<String> currentUserParticipantIds,
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

      if (!currentUserParticipantIds.contains(transaction.senderId)) {
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

      if (!currentUserParticipantIds.contains(transaction.beneficiaryId)) {
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
