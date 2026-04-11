import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

class LocalTransactionFriendMatcher {
  const LocalTransactionFriendMatcher();

  FriendsModel? findMatch(
    Iterable<FriendsModel> localFriends,
    FriendsModel friend, {
    required int transactionType,
  }) {
    final normalizedUsername = _normalize(friend.username);
    final normalizedEmail = _normalize(friend.email);
    final relationType = FriendConst.getTypeOfFriend(transactionType);

    if (normalizedUsername.isEmpty && normalizedEmail.isEmpty) {
      return null;
    }

    final sameNameAndType = localFriends
        .where(
          (candidate) =>
              candidate.relationType == relationType &&
              _normalize(candidate.username) == normalizedUsername,
        )
        .toList(growable: false);

    if (sameNameAndType.isEmpty) {
      return null;
    }

    if (normalizedEmail.isNotEmpty) {
      for (final candidate in sameNameAndType) {
        if (_normalize(candidate.email) == normalizedEmail) {
          return candidate;
        }
      }
      return null;
    }

    for (final candidate in sameNameAndType) {
      if (_normalize(candidate.email).isEmpty) {
        return candidate;
      }
    }

    return sameNameAndType.length == 1 ? sameNameAndType.first : null;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
