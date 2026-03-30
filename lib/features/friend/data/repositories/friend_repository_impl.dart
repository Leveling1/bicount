import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/constants/app_config.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_core/query.dart';
import 'package:bicount/features/friend/data/data_sources/local_datasource/friend_local_datasource.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/friend_remote_datasource.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/domain/repositories/friend_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final FriendLocalDataSource localDataSource;
  final FriendRemoteDataSource remoteDataSource;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<void> acceptInvite(String inviteCode) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw AuthException('You must be logged in to accept an invitation.');
    }

    await remoteDataSource.acceptInvite(inviteCode, currentUserId);
  }

  @override
  Future<FriendShareEntity> createInvite({
    required String senderName,
    required String senderEmail,
    required String senderImage,
    required String sourceFriendSid,
    required String sourceFriendName,
    required String sourceFriendEmail,
    required String sourceFriendImage,
  }) async {
    final inviteCode = const Uuid().v4();
    final now = DateTime.now();
    final share = FriendShareEntity(
      inviteId: const Uuid().v4(),
      inviteCode: inviteCode,
      inviteUrl: AppConfig.buildInviteUrl(inviteCode),
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      sourceFriendSid: sourceFriendSid,
      sourceFriendName: sourceFriendName,
      sourceFriendEmail: sourceFriendEmail,
      sourceFriendImage: sourceFriendImage,
    );

    await localDataSource.cacheActiveShare(share);

    try {
      await remoteDataSource.createInvite(
        share: share,
        senderName: senderName,
        senderEmail: senderEmail,
        senderImage: senderImage,
      );
    } catch (_) {
      // The local cache keeps the share flow usable offline while the backend
      // handoff is being completed.
    }

    return share;
  }

  @override
  String? extractInviteCode(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        return code;
      }
    }

    final directCode = trimmed.replaceAll(' ', '');
    return directCode.isEmpty ? null : directCode;
  }

  @override
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode) async {
    try {
      final invite = await remoteDataSource.getInviteByCode(inviteCode);
      if (invite != null) {
        final cachedInvites = await localDataSource.getCachedInvites();
        final mergedInvites = [
          invite,
          ...cachedInvites.where(
            (item) => item.inviteCode != invite.inviteCode,
          ),
        ];
        await localDataSource.cacheInvites(mergedInvites);
      }
      return invite;
    } catch (_) {
      final cachedInvites = await localDataSource.getCachedInvites();
      for (final invite in cachedInvites) {
        if (invite.inviteCode == inviteCode) {
          return invite;
        }
      }
      return null;
    }
  }

  @override
  Future<void> rejectInvite(String inviteCode) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw AuthException('You must be logged in to reject an invitation.');
    }

    await remoteDataSource.rejectInvite(inviteCode, currentUserId);
  }

  @override
  Future<void> updateFriendProfile({
    required FriendsModel friend,
    required String username,
    required String image,
  }) async {
    if ((friend.uid ?? '').isNotEmpty ||
        friend.relationType == FriendConst.subscription) {
      throw MessageFailure(message: 'Unable to update this friend right now.');
    }

    try {
      final currentFriends = await Repository().get<FriendsModel>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where.exact('sid', friend.sid)]),
      );
      final currentFriend = currentFriends.isEmpty ? friend : currentFriends.first;

      final updatedFriend = FriendsModel(
        sid: currentFriend.sid,
        uid: currentFriend.uid,
        fid: currentFriend.fid,
        image: image.isEmpty ? currentFriend.image : image,
        username: username.trim(),
        email: currentFriend.email,
        give: currentFriend.give,
        receive: currentFriend.receive,
        relationType: currentFriend.relationType,
        personalIncome: currentFriend.personalIncome,
        companyIncome: currentFriend.companyIncome,
      )..primaryKey = currentFriend.primaryKey;

      await Repository().upsert<FriendsModel>(updatedFriend);
    } catch (_) {
      throw MessageFailure(message: 'Unable to update this friend right now.');
    }
  }

  @override
  Stream<FriendHubEntity> watchHub() async* {
    final activeShare = await localDataSource.getActiveShare();
    final cachedInvites = await localDataSource.getCachedInvites();
    final currentUserId = _currentUserId;

    yield _buildHub(
      activeShare: activeShare,
      invites: cachedInvites,
      currentUserId: currentUserId,
    );

    if (currentUserId == null) {
      return;
    }

    yield* remoteDataSource.watchInvites(currentUserId).asyncMap((
      invites,
    ) async {
      await localDataSource.cacheInvites(invites);
      final refreshedShare = await localDataSource.getActiveShare();
      return _buildHub(
        activeShare: refreshedShare,
        invites: invites,
        currentUserId: currentUserId,
      );
    });
  }

  FriendHubEntity _buildHub({
    required FriendShareEntity? activeShare,
    required List<FriendInviteEntity> invites,
    required String? currentUserId,
  }) {
    if (currentUserId == null) {
      return FriendHubEntity(
        activeShare: activeShare,
        sentInvites: const [],
        receivedInvites: const [],
      );
    }

    return FriendHubEntity(
      activeShare: activeShare,
      sentInvites: invites
          .where((invite) => invite.senderUid == currentUserId)
          .toList(),
      receivedInvites: invites
          .where((invite) => invite.receiverUid == currentUserId)
          .toList(),
    );
  }
}
