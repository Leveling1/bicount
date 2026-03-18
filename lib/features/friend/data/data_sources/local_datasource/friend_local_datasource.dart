import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';

abstract class FriendLocalDataSource {
  Future<void> cacheActiveShare(FriendShareEntity share);
  Future<FriendShareEntity?> getActiveShare();
  Future<void> cacheInvites(List<FriendInviteEntity> invites);
  Future<List<FriendInviteEntity>> getCachedInvites();
}
