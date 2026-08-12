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

  /// Newest still-pending, still-valid invitation this user already created
  /// for [sourceFriendSid], so opening the share screen reuses it instead of
  /// piling up a new row every time.
  Future<FriendInviteEntity?> findReusableInvite({
    required String sourceFriendSid,
    required String currentUserId,
  });

  /// Breaks the link on both sides at once. Returns the profile ids that
  /// stopped being shared.
  Future<List<String>> unlinkAccounts(String friendSid);
}
