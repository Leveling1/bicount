import 'package:bicount/features/friend/data/data_sources/remote_datasource/friend_remote_datasource.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFriendRemoteDataSource implements FriendRemoteDataSource {
  SupabaseFriendRemoteDataSource(this.client);

  final SupabaseClient client;

  @override
  Future<void> acceptInvite(String inviteCode, String currentUserId) async {
    try {
      await client.rpc(
        'accept_friend_invite',
        params: {'p_invite_code': inviteCode, 'p_receiver_uid': currentUserId},
      );
    } on PostgrestException {
      await client
          .from('friend_invites')
          .update({
            'status': FriendInviteStatus.accepted.value,
            'receiver_uid': currentUserId,
          })
          .eq('invite_code', inviteCode);
    }
  }

  @override
  Future<void> createInvite({
    required FriendShareEntity share,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  }) async {
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw AuthException('You must be logged in to invite a friend.');
    }

    await client.from('friend_invites').upsert({
      'invite_id': share.inviteId,
      'invite_code': share.inviteCode,
      'sender_uid': currentUserId,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'sender_image': senderImage,
      'status': FriendInviteStatus.pending.value,
      'created_at': share.createdAt.toUtc().toIso8601String(),
      'expires_at': share.expiresAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode) async {
    final response = await client
        .from('friend_invites')
        .select()
        .eq('invite_code', inviteCode)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return _mapInvite(response);
  }

  @override
  Future<void> rejectInvite(String inviteCode, String currentUserId) async {
    await client
        .from('friend_invites')
        .update({
          'status': FriendInviteStatus.rejected.value,
          'receiver_uid': currentUserId,
        })
        .eq('invite_code', inviteCode);
  }

  @override
  Stream<List<FriendInviteEntity>> watchInvites(String currentUserId) {
    return client.from('friend_invites').stream(primaryKey: ['invite_id']).map((
      rows,
    ) {
      return rows
          .map(_mapInvite)
          .where(
            (invite) =>
                invite.senderUid == currentUserId ||
                invite.receiverUid == currentUserId,
          )
          .toList()
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    });
  }

  FriendInviteEntity _mapInvite(Map<String, dynamic> map) {
    return FriendInviteEntity(
      inviteId: map['invite_id'] as String,
      inviteCode: map['invite_code'] as String,
      senderUid: map['sender_uid'] as String,
      senderName: map['sender_name'] as String? ?? 'Bicount user',
      senderEmail: map['sender_email'] as String? ?? '',
      senderImage: map['sender_image'] as String? ?? '',
      receiverUid: map['receiver_uid'] as String?,
      receiverName: map['receiver_name'] as String?,
      status: FriendInviteStatusX.fromValue(map['status'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
    );
  }
}
