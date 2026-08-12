import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/domain/entities/friend_link_entities.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

abstract class FriendRepository {
  Stream<FriendHubEntity> watchHub();

  /// Returns a shareable invitation for [sourceFriendSid]. Reuses the profile's
  /// still-valid invitation when there is one, so simply opening the share
  /// screen never creates a new code. Pass [forceNew] to deliberately replace
  /// it.
  Future<FriendShareEntity> createInvite({
    required String senderName,
    required String senderEmail,
    required String senderImage,
    required String sourceFriendSid,
    required String sourceFriendName,
    required String sourceFriendEmail,
    required String sourceFriendImage,
    bool forceNew = false,
  });

  /// Breaks the link between the two accounts on both sides. Nothing is
  /// deleted: each side keeps its profile and its own history.
  Future<FriendUnlinkResult> unlinkFriend(FriendsModel friend);

  /// Counts what deleting [friend] would erase, so the confirmation can show
  /// real numbers.
  Future<FriendDeletionImpact> friendDeletionImpact(FriendsModel friend);

  /// Permanently deletes an unlinked profile together with everything
  /// recorded against it.
  Future<void> deleteFriendWithHistory(FriendsModel friend);
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
