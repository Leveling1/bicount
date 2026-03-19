import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';

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
  String? extractInviteCode(String rawValue);
}
