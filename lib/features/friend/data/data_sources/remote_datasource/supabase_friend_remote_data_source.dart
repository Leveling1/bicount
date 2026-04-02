import 'dart:io';

import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/friend_remote_datasource.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFriendRemoteDataSource implements FriendRemoteDataSource {
  SupabaseFriendRemoteDataSource(this.client);

  final SupabaseClient client;
  static const _previewFunctionName = 'friend-invite-preview';
  static const _acceptFunctionName = 'accept-friend-invite';

  @override
  Future<void> acceptInvite(String inviteCode, String currentUserId) async {
    try {
      await _ensureOnline('Connect to the internet to accept this invitation.');
      await client.functions.invoke(
        _acceptFunctionName,
        body: {'invite_code': inviteCode},
      );
    } on MessageFailure {
      rethrow;
    } on AuthException {
      throw MessageFailure(message: 'Sign in to accept this invitation.');
    } on SocketException {
      throw MessageFailure(
        message: 'Connect to the internet to accept this invitation.',
      );
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to accept this invitation right now.',
      );
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

    final payload = {
      'invite_id': share.inviteId,
      'invite_code': share.inviteCode,
      'sender_uid': currentUserId,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'sender_image': senderImage,
      'status_id': AppFriendInviteState.pending,
      'created_at': share.createdAt.toUtc().toIso8601String(),
      'expires_at': share.expiresAt.toUtc().toIso8601String(),
      'source_friend_sid': share.sourceFriendSid,
      'source_friend_name': share.sourceFriendName,
      'source_friend_email': share.sourceFriendEmail,
      'source_friend_image': share.sourceFriendImage,
    };

    try {
      await client.from('friend_invites').upsert(payload);
    } on PostgrestException {
      await client.from('friend_invites').upsert({
        ...payload,
        'status': 'pending',
      }..remove('status_id'));
    }
  }

  @override
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode) async {
    try {
      await _ensureOnline('Connect to the internet to load this invitation.');
      final response = await client.functions.invoke(
        _previewFunctionName,
        body: {'invite_code': inviteCode},
      );
      final inviteMap = _extractInviteMap(response.data);
      if (inviteMap == null) {
        return null;
      }

      return _mapInvite(inviteMap);
    } on MessageFailure {
      rethrow;
    } on SocketException {
      throw MessageFailure(
        message: 'Connect to the internet to load this invitation.',
      );
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to load this invitation right now.',
      );
    }
  }

  @override
  Future<void> rejectInvite(String inviteCode, String currentUserId) async {
    try {
      await _ensureOnline('Connect to the internet to reject this invitation.');
      await client
          .from('friend_invites')
          .update({
            'status_id': AppFriendInviteState.rejected,
            'receiver_uid': currentUserId,
          })
          .eq('invite_code', inviteCode);
    } on PostgrestException {
      await client
          .from('friend_invites')
          .update({
            'status': 'rejected',
            'receiver_uid': currentUserId,
          })
          .eq('invite_code', inviteCode);
    } on MessageFailure {
      rethrow;
    } on SocketException {
      throw MessageFailure(
        message: 'Connect to the internet to reject this invitation.',
      );
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to reject this invitation right now.',
      );
    }
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
      statusId: AppFriendInviteState.fromRaw(map['status_id'] ?? map['status']),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
      sourceFriendSid: map['source_friend_sid'] as String?,
      sourceFriendName: map['source_friend_name'] as String?,
      sourceFriendEmail: map['source_friend_email'] as String?,
      sourceFriendImage: map['source_friend_image'] as String?,
    );
  }

  Map<String, dynamic>? _extractInviteMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nestedInvite = data['invite'];
      if (nestedInvite is Map<String, dynamic>) {
        return nestedInvite;
      }
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
      return data;
    }
    return null;
  }

  Future<void> _ensureOnline(String message) async {
    final hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      throw MessageFailure(message: message);
    }
  }
}
