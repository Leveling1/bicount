part of 'main_finance_projection_service.dart';

extension on MainFinanceProjectionService {
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
      final currencyCode = CurrencyConfigEntity.normalizeCode(
        transaction.currency,
      );

      if (!currentUserParticipantIds.contains(transaction.senderId)) {
        final sender = aggregatesById[transaction.senderId];
        sender?.apply(
          nativeAmount: transaction.amount,
          currencyCode: currencyCode,
          category: category,
          isSender: true,
        );
      }

      if (!currentUserParticipantIds.contains(transaction.beneficiaryId)) {
        final beneficiary = aggregatesById[transaction.beneficiaryId];
        beneficiary?.apply(
          nativeAmount: transaction.amount,
          currencyCode: currencyCode,
          category: category,
          isSender: false,
        );
      }
    }

    return friends
        .map(
          (friend) => aggregatesById[friend.sid]!.toModel(this, currencyConfig),
        )
        .toList();
  }
}
