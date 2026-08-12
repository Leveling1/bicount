import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';

abstract class FriendLocalDataSource {
  Future<void> cacheActiveShare(FriendShareEntity share);

  /// Reads the share cached for [sourceFriendSid]. Without it, returns the
  /// most recently cached share whichever profile it belongs to.
  Future<FriendShareEntity?> getActiveShare({String? sourceFriendSid});
  Future<void> cacheInvites(List<FriendInviteEntity> invites);
  Future<List<FriendInviteEntity>> getCachedInvites();
}
