import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

class DebtPermissionService {
  const DebtPermissionService({
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final TransactionParticipantIdentityService participantIdentityService;

  bool canRecordPayment({
    required DebtModel debt,
    required String currentUserId,
    required List<FriendsModel> friends,
  }) {
    final participantIds = participantIdentityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );
    final bothLinkedToAccounts =
        _resolveAccountId(debt.lenderId, friends, currentUserId) != null &&
        _resolveAccountId(debt.borrowerId, friends, currentUserId) != null;

    if (bothLinkedToAccounts) {
      return participantIds.contains(debt.lenderId);
    }

    return debt.createdBy == currentUserId;
  }

  String? resolveAccountId(
    String partyId,
    List<FriendsModel> friends,
    String currentUserId,
  ) {
    if (partyId == currentUserId) {
      return currentUserId;
    }

    for (final friend in friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        final linkedUid = friend.uid;
        if (linkedUid != null && linkedUid.isNotEmpty) {
          return linkedUid;
        }
      }
    }

    return null;
  }

  String? _resolveAccountId(
    String partyId,
    List<FriendsModel> friends,
    String currentUserId,
  ) {
    return resolveAccountId(partyId, friends, currentUserId);
  }
}
