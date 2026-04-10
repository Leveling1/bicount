import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/friend/domain/entities/friend_detail_entity.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class FriendViewService {
  const FriendViewService({
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final TransactionParticipantIdentityService participantIdentityService;

  FriendDetailEntity buildDetail({
    required MainEntity data,
    required FriendsModel fallbackFriend,
  }) {
    final friend = data.friends.firstWhere(
      (candidate) => candidate.sid == fallbackFriend.sid,
      orElse: () => fallbackFriend,
    );
    final friendParticipantIds = participantIdentityService
        .friendParticipantIds(friend);
    final transactions =
        data.transactions
            .where(
              (transaction) =>
                  participantIdentityService.transactionInvolvesAnyParticipant(
                    transaction,
                    friendParticipantIds,
                  ),
            )
            .toList()
          ..sort(
            (left, right) =>
                _resolveSortDate(right).compareTo(_resolveSortDate(left)),
          );

    final totalGiven = friend.give ?? 0;
    final totalReceived = friend.receive ?? 0;

    final canShareProfile = isShareableFriend(friend);

    return FriendDetailEntity(
      friend: friend,
      transactions: transactions,
      displayCurrencyCode: data.referenceCurrencyCode,
      totalGiven: totalGiven,
      totalReceived: totalReceived,
      netBalance: totalReceived - totalGiven,
      canShareProfile: canShareProfile,
      isLinkedProfile: !canShareProfile,
    );
  }

  bool isShareableFriend(FriendsModel friend) {
    final uid = friend.uid;
    return uid == null || uid.isEmpty;
  }

  List<FriendsModel> visibleFriends(
    List<FriendsModel> friends, {
    String? currentUserUid,
  }) {
    final filtered = friends.where((friend) {
      if (friend.relationType != FriendConst.friend) {
        return false;
      }
      if (currentUserUid != null && friend.uid == currentUserUid) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((left, right) {
      final rightVolume = (right.give ?? 0).abs() + (right.receive ?? 0).abs();
      final leftVolume = (left.give ?? 0).abs() + (left.receive ?? 0).abs();
      final volumeComparison = rightVolume.compareTo(leftVolume);
      if (volumeComparison != 0) {
        return volumeComparison;
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
