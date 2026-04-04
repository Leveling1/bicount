import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class TransactionParticipantIdentityService {
  const TransactionParticipantIdentityService();

  Set<String> currentUserParticipantIds({
    required String currentUserId,
    required List<FriendsModel> friends,
  }) {
    final ids = <String>{currentUserId};

    for (final friend in friends) {
      final linkedUid = friend.uid;
      if (linkedUid == null || linkedUid.isEmpty) {
        continue;
      }
      if (linkedUid == currentUserId) {
        ids.add(friend.sid);
        ids.add(linkedUid);
      }
    }

    return ids;
  }

  Set<String> friendParticipantIds(FriendsModel friend) {
    final ids = <String>{friend.sid};
    final linkedUid = friend.uid;
    if (linkedUid != null && linkedUid.isNotEmpty) {
      ids.add(linkedUid);
    }
    return ids;
  }

  bool transactionInvolvesAnyParticipant(
    TransactionModel transaction,
    Set<String> participantIds,
  ) {
    return participantIds.contains(transaction.senderId) ||
        participantIds.contains(transaction.beneficiaryId);
  }

  List<TransactionModel> filterTransactionsForCurrentUser({
    required String currentUserId,
    required List<FriendsModel> friends,
    required List<TransactionModel> transactions,
  }) {
    final participantIds = currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );

    return transactions
        .where((transaction) {
          return transaction.uid == currentUserId ||
              transactionInvolvesAnyParticipant(transaction, participantIds);
        })
        .toList(growable: false);
  }
}
