import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/friend/domain/entities/friend_detail_entity.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class FriendViewService {
  const FriendViewService();

  FriendDetailEntity buildDetail({
    required MainEntity data,
    required FriendsModel fallbackFriend,
  }) {
    final friend = data.friends.firstWhere(
      (candidate) => candidate.sid == fallbackFriend.sid,
      orElse: () => fallbackFriend,
    );
    final transactions =
        data.transactions
            .where(
              (transaction) =>
                  transaction.senderId == friend.sid ||
                  transaction.beneficiaryId == friend.sid,
            )
            .toList()
          ..sort(
            (left, right) =>
                _resolveSortDate(right).compareTo(_resolveSortDate(left)),
          );

    final totalGiven = transactions
        .where(
          (transaction) =>
              transaction.senderId == data.user.sid &&
              transaction.beneficiaryId == friend.sid,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    final totalReceived = transactions
        .where(
          (transaction) =>
              transaction.senderId == friend.sid &&
              transaction.beneficiaryId == data.user.sid,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    final canShareProfile = isShareableFriend(friend, ownerUid: data.user.uid);

    return FriendDetailEntity(
      friend: friend,
      transactions: transactions,
      totalGiven: totalGiven,
      totalReceived: totalReceived,
      netBalance: totalReceived - totalGiven,
      canShareProfile: canShareProfile,
      isLinkedProfile: !canShareProfile,
    );
  }

  bool isShareableFriend(FriendsModel friend, {String? ownerUid}) {
    final uid = friend.uid;
    if (uid == null || uid.isEmpty) {
      return true;
    }

    return ownerUid != null && friend.fid == ownerUid && uid == friend.sid;
  }

  List<FriendsModel> visibleFriends(
    List<FriendsModel> friends, {
    String? currentUserUid,
    String? currentUserSid,
  }) {
    final filtered = friends.where((friend) {
      if (friend.relationType == FriendConst.subscription) {
        return false;
      }
      if (currentUserSid != null && friend.sid == currentUserSid) {
        return false;
      }
      if (currentUserUid != null && friend.uid == currentUserUid) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((left, right) {
      final rightScore = (right.receive ?? 0) - (right.give ?? 0);
      final leftScore = (left.receive ?? 0) - (left.give ?? 0);
      final balanceComparison = rightScore.compareTo(leftScore);
      if (balanceComparison != 0) {
        return balanceComparison;
      }
      return left.username.toLowerCase().compareTo(
        right.username.toLowerCase(),
      );
    });

    return filtered;
  }

  DateTime _resolveSortDate(TransactionModel transaction) {
    return DateTime.tryParse(transaction.date) ??
        DateTime.tryParse(transaction.createdAt ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
