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

  /// All identifiers known to represent any of the current user's tracked
  /// friends (their local relationship id and, when linked, their real
  /// account id). Used together with [isMineWithFallback] to recognize the
  /// current user's own side of a record even when it wasn't recorded with
  /// their raw id.
  Set<String> knownFriendParticipantIds(List<FriendsModel> friends) {
    final ids = <String>{};
    for (final friend in friends) {
      ids.addAll(friendParticipantIds(friend));
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

  /// Deterministic identity check: true when [candidateId] is the current
  /// user's own raw id, or the local relationship id of one of the current
  /// user's own linked profiles (a friend row whose `uid` equals the current
  /// user's uid — see [currentUserParticipantIds]). This is the single
  /// source of truth for "is this id me" and should be preferred everywhere
  /// over ad-hoc `Set.contains` checks.
  bool isMe({
    required String candidateId,
    required Set<String> currentUserParticipantIds,
  }) {
    return currentUserParticipantIds.contains(candidateId);
  }

  /// Whether [candidateId] should be treated as the current user's side of a
  /// two-party record (transaction sender/beneficiary, debt lender/borrower).
  ///
  /// Tries [isMe] first. A record shared between the current user and a
  /// friend can be recorded from either device though, so [candidateId] is
  /// not always the current user's raw id — it can be a local friend
  /// identifier assigned by the *other* linked account, one this device has
  /// never seen. When [isMe] doesn't recognize [candidateId], fall back to
  /// elimination: the record is only visible on this device because the
  /// current user is a party to it, so if [counterpartId] is a known friend
  /// and [candidateId] isn't (and isn't the current user either),
  /// [candidateId] must be the current user.
  bool isMineWithFallback({
    required String candidateId,
    required String counterpartId,
    required Set<String> currentUserParticipantIds,
    required Set<String> knownFriendParticipantIds,
  }) {
    if (isMe(
      candidateId: candidateId,
      currentUserParticipantIds: currentUserParticipantIds,
    )) {
      return true;
    }
    return knownFriendParticipantIds.contains(counterpartId) &&
        !knownFriendParticipantIds.contains(candidateId) &&
        !currentUserParticipantIds.contains(counterpartId);
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
    final knownFriendIds = knownFriendParticipantIds(friends);

    return transactions
        .where((transaction) {
          if (transaction.uid == currentUserId ||
              transactionInvolvesAnyParticipant(transaction, participantIds)) {
            return true;
          }
          return isMineWithFallback(
                candidateId: transaction.senderId,
                counterpartId: transaction.beneficiaryId,
                currentUserParticipantIds: participantIds,
                knownFriendParticipantIds: knownFriendIds,
              ) ||
              isMineWithFallback(
                candidateId: transaction.beneficiaryId,
                counterpartId: transaction.senderId,
                currentUserParticipantIds: participantIds,
                knownFriendParticipantIds: knownFriendIds,
              );
        })
        .toList(growable: false);
  }
}
