import 'dart:convert';

import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/features/friend/data/data_sources/local_datasource/friend_local_datasource.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFriendDataSourceImpl implements FriendLocalDataSource {
  static const _activeShareKey = 'friend_active_share_v1';
  static const _cachedInvitesKey = 'friend_cached_invites_v1';

  @override
  Future<void> cacheActiveShare(FriendShareEntity share) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _activeShareKey,
      jsonEncode({
        'invite_id': share.inviteId,
        'invite_code': share.inviteCode,
        'invite_url': share.inviteUrl,
        'created_at': share.createdAt.toIso8601String(),
        'expires_at': share.expiresAt.toIso8601String(),
        'source_friend_sid': share.sourceFriendSid,
        'source_friend_name': share.sourceFriendName,
        'source_friend_email': share.sourceFriendEmail,
        'source_friend_image': share.sourceFriendImage,
      }),
    );
  }

  @override
  Future<void> cacheInvites(List<FriendInviteEntity> invites) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = invites
        .map(
          (invite) => {
            'invite_id': invite.inviteId,
            'invite_code': invite.inviteCode,
            'sender_uid': invite.senderUid,
            'sender_name': invite.senderName,
            'sender_email': invite.senderEmail,
            'sender_image': invite.senderImage,
            'receiver_uid': invite.receiverUid,
            'receiver_name': invite.receiverName,
            'status_id': invite.statusId,
            'created_at': invite.createdAt.toIso8601String(),
            'expires_at': invite.expiresAt.toIso8601String(),
            'source_friend_sid': invite.sourceFriendSid,
            'source_friend_name': invite.sourceFriendName,
            'source_friend_email': invite.sourceFriendEmail,
            'source_friend_image': invite.sourceFriendImage,
          },
        )
        .toList();
    await preferences.setString(_cachedInvitesKey, jsonEncode(payload));
  }

  @override
  Future<FriendShareEntity?> getActiveShare() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_activeShareKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final map = jsonDecode(rawValue) as Map<String, dynamic>;
    return FriendShareEntity(
      inviteId: map['invite_id'] as String,
      inviteCode: map['invite_code'] as String,
      inviteUrl: map['invite_url'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
      sourceFriendSid: map['source_friend_sid'] as String?,
      sourceFriendName: map['source_friend_name'] as String?,
      sourceFriendEmail: map['source_friend_email'] as String?,
      sourceFriendImage: map['source_friend_image'] as String?,
    );
  }

  @override
  Future<List<FriendInviteEntity>> getCachedInvites() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_cachedInvitesKey);
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    final list = (jsonDecode(rawValue) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return list
        .map(
          (map) => FriendInviteEntity(
            inviteId: map['invite_id'] as String,
            inviteCode: map['invite_code'] as String,
            senderUid: map['sender_uid'] as String,
            senderName: map['sender_name'] as String,
            senderEmail: map['sender_email'] as String,
            senderImage: map['sender_image'] as String? ?? '',
            receiverUid: map['receiver_uid'] as String?,
            receiverName: map['receiver_name'] as String?,
            statusId: AppFriendInviteState.fromRaw(
              map['status_id'] ?? map['status'],
            ),
            createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
            expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
            sourceFriendSid: map['source_friend_sid'] as String?,
            sourceFriendName: map['source_friend_name'] as String?,
            sourceFriendEmail: map['source_friend_email'] as String?,
            sourceFriendImage: map['source_friend_image'] as String?,
          ),
        )
        .toList();
  }
}
