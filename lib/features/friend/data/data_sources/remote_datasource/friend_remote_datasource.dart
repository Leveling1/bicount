import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';

abstract class FriendRemoteDataSource {
  Stream<List<FriendInviteEntity>> watchInvites(String currentUserId);
  Future<void> createInvite({
    required FriendShareEntity share,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  });
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode);
  Future<void> acceptInvite(String inviteCode, String currentUserId);
  Future<void> rejectInvite(String inviteCode, String currentUserId);
}
