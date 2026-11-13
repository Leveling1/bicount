part of 'debt_repository_impl.dart';

extension on DebtRepositoryImpl {
  Future<bool> _isWalletParty(String partyId) async {
    final uid = _currentUserId;
    if (uid == null) return false;
    if (uid == partyId) return true;
    final friends = await Repository().localGet<FriendsModel>();
    return participantIdentityService
        .currentUserParticipantIds(currentUserId: uid, friends: friends)
        .contains(partyId);
  }

  Future<void> _ensureCanRecordPayment(DebtModel debt) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw AuthenticationFailure(message: 'Authentication failure');
    }

    final friends = await Repository().get<FriendsModel>(
      policy: OfflineReadPolicy.localOnly,
    );
    final participantIds = participantIdentityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );
    final bothLinkedToAccounts =
        _resolveAccountId(debt.lenderId, friends, currentUserId) != null &&
        _resolveAccountId(debt.borrowerId, friends, currentUserId) != null;

    if (bothLinkedToAccounts) {
      if (!participantIds.contains(debt.lenderId)) {
        throw MessageFailure(
          message: 'Only the lender can confirm received repayments.',
        );
      }
      return;
    }

    if (debt.createdBy != currentUserId) {
      throw MessageFailure(
        message: 'Only the creator can update this debt for now.',
      );
    }
  }

  Future<void> _ensureCanManageContract(
    DebtModel debt, {
    required String failureMessage,
  }) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw AuthenticationFailure(message: 'Authentication failure');
    }
    if (debt.createdBy != currentUserId) {
      throw MessageFailure(message: failureMessage);
    }
  }

  String? _resolveAccountId(
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
        if (friend.sid == currentUserId) {
          return currentUserId;
        }
      }
    }

    return null;
  }
}
