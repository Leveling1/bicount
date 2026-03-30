import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

abstract class FriendRepository {
  Stream<FriendHubEntity> watchHub();
  Future<FriendShareEntity> createInvite({
    required String senderName,
    required String senderEmail,
    required String senderImage,
    required String sourceFriendSid,
    required String sourceFriendName,
    required String sourceFriendEmail,
    required String sourceFriendImage,
  });
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode);
  Future<void> acceptInvite(String inviteCode);
  Future<void> rejectInvite(String inviteCode);
  Future<void> updateFriendProfile({
    required FriendsModel friend,
    required String username,
    required String image,
  });
  String? extractInviteCode(String rawValue);
}
