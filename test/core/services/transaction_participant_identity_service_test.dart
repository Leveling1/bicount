import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TransactionParticipantIdentityService();

  FriendsModel selfLinkedProfile({String sid = 'self-profile-sid'}) {
    return FriendsModel(
      sid: sid,
      uid: 'user-1',
      image: '',
      username: 'Moi (autre profil)',
      email: '',
      relationType: FriendConst.friend,
    );
  }

  FriendsModel realFriend({String sid = 'friend-sid', String? uid}) {
    return FriendsModel(
      sid: sid,
      uid: uid,
      image: '',
      username: 'Ami',
      email: '',
      relationType: FriendConst.friend,
    );
  }

  group('isMe', () {
    test('recognizes the current user raw id', () {
      final participantIds = service.currentUserParticipantIds(
        currentUserId: 'user-1',
        friends: [realFriend()],
      );

      expect(
        service.isMe(
          candidateId: 'user-1',
          currentUserParticipantIds: participantIds,
        ),
        isTrue,
      );
    });

    test(
      'recognizes a linked self profile local id (friend.uid == currentUserId)',
      () {
        final participantIds = service.currentUserParticipantIds(
          currentUserId: 'user-1',
          friends: [selfLinkedProfile(sid: 'self-profile-sid')],
        );

        expect(
          service.isMe(
            candidateId: 'self-profile-sid',
            currentUserParticipantIds: participantIds,
          ),
          isTrue,
        );
      },
    );

    test('rejects a real friend id', () {
      final participantIds = service.currentUserParticipantIds(
        currentUserId: 'user-1',
        friends: [realFriend(sid: 'friend-sid', uid: 'friend-real-uid')],
      );

      expect(
        service.isMe(
          candidateId: 'friend-sid',
          currentUserParticipantIds: participantIds,
        ),
        isFalse,
      );
    });
  });

  group('isMineWithFallback', () {
    test('matches directly through isMe without needing elimination', () {
      final participantIds = service.currentUserParticipantIds(
        currentUserId: 'user-1',
        friends: [selfLinkedProfile(sid: 'self-profile-sid')],
      );
      final knownFriendIds = service.knownFriendParticipantIds([
        selfLinkedProfile(sid: 'self-profile-sid'),
        realFriend(sid: 'friend-sid', uid: 'friend-real-uid'),
      ]);

      expect(
        service.isMineWithFallback(
          candidateId: 'self-profile-sid',
          counterpartId: 'friend-sid',
          currentUserParticipantIds: participantIds,
          knownFriendParticipantIds: knownFriendIds,
        ),
        isTrue,
      );
    });

    test(
      'falls back to elimination when the counterpart is a known friend and '
      'the candidate is a totally unrecognized id',
      () {
        final participantIds = service.currentUserParticipantIds(
          currentUserId: 'user-1',
          friends: [realFriend(sid: 'friend-sid', uid: 'friend-real-uid')],
        );
        final knownFriendIds = service.knownFriendParticipantIds([
          realFriend(sid: 'friend-sid', uid: 'friend-real-uid'),
        ]);

        expect(
          service.isMineWithFallback(
            candidateId: 'never-seen-id',
            counterpartId: 'friend-sid',
            currentUserParticipantIds: participantIds,
            knownFriendParticipantIds: knownFriendIds,
          ),
          isTrue,
        );
      },
    );

    test('does not fall back when the counterpart is not a known friend', () {
      final participantIds = service.currentUserParticipantIds(
        currentUserId: 'user-1',
        friends: const [],
      );
      final knownFriendIds = service.knownFriendParticipantIds(const []);

      expect(
        service.isMineWithFallback(
          candidateId: 'never-seen-id',
          counterpartId: 'also-never-seen-id',
          currentUserParticipantIds: participantIds,
          knownFriendParticipantIds: knownFriendIds,
        ),
        isFalse,
      );
    });
  });

  group('filterTransactionsForCurrentUser', () {
    test(
      'includes income routed through a linked self profile (friend.uid == '
      'currentUserId)',
      () {
        final transactions = [
          TransactionModel(
            uid: 'someone-else',
            gtid: 'gtid-income',
            name: 'Income via linked profile',
            type: 0,
            beneficiaryId: 'self-profile-sid',
            senderId: 'external-payer',
            date: '2026-04-01',
            note: '',
            amount: 100,
            currency: 'USD',
          ),
        ];

        final result = service.filterTransactionsForCurrentUser(
          currentUserId: 'user-1',
          friends: [selfLinkedProfile(sid: 'self-profile-sid')],
          transactions: transactions,
        );

        expect(result, hasLength(1));
        expect(result.single.gtid, 'gtid-income');
      },
    );
  });
}
