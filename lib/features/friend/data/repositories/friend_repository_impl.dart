import 'dart:async';

import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/constants/app_config.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:bicount/features/friend/data/data_sources/local_datasource/friend_local_datasource.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/friend_remote_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/domain/entities/friend_link_entities.dart';
import 'package:bicount/features/friend/domain/repositories/friend_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final FriendLocalDataSource localDataSource;
  final FriendRemoteDataSource remoteDataSource;

  String? get _currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      // No initialised client (tests, very early startup): treat it as signed
      // out rather than blowing up the caller.
      return null;
    }
  }

  @override
  Future<void> acceptInvite(String inviteCode) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw MessageFailure(message: 'Sign in to accept this invitation.');
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
    bool forceNew = false,
  }) async {
    if (!forceNew) {
      final reusable = await _findReusableShare(
        sourceFriendSid: sourceFriendSid,
        senderName: senderName,
        senderEmail: senderEmail,
        senderImage: senderImage,
      );
      if (reusable != null) {
        return reusable;
      }
    }

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
      isSynced: false,
    );

    final synced = await _pushInvite(
      share: share,
      senderName: senderName,
      senderEmail: senderEmail,
      senderImage: senderImage,
    );

    await localDataSource.cacheActiveShare(synced);
    return synced;
  }

  /// Existing code for this profile, either the one cached on this device or
  /// the newest pending invitation the backend still holds.
  Future<FriendShareEntity?> _findReusableShare({
    required String sourceFriendSid,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  }) async {
    final cached = await localDataSource.getActiveShare(
      sourceFriendSid: sourceFriendSid,
    );
    final usableCache =
        cached != null &&
            cached.sourceFriendSid == sourceFriendSid &&
            !cached.isExpired
        ? cached
        : null;

    if (usableCache != null && usableCache.isSynced) {
      return usableCache;
    }

    // Asked before any retry: a code created offline may in fact have reached
    // the backend, and re-sending it would clash with the stored row.
    final currentUserId = _currentUserId;
    if (currentUserId != null) {
      try {
        final invite = await remoteDataSource.findReusableInvite(
          sourceFriendSid: sourceFriendSid,
          currentUserId: currentUserId,
        );
        if (invite != null) {
          final share = FriendShareEntity(
            inviteId: invite.inviteId,
            inviteCode: invite.inviteCode,
            inviteUrl: AppConfig.buildInviteUrl(invite.inviteCode),
            createdAt: invite.createdAt,
            expiresAt: invite.expiresAt,
            sourceFriendSid: invite.sourceFriendSid,
            sourceFriendName: invite.sourceFriendName,
            sourceFriendEmail: invite.sourceFriendEmail,
            sourceFriendImage: invite.sourceFriendImage,
          );
          await localDataSource.cacheActiveShare(share);
          return share;
        }
        if (usableCache == null) {
          return null;
        }
      } catch (_) {
        // Offline or unreachable: fall through to the cached code below.
      }
    }

    if (usableCache == null) {
      return null;
    }

    // Created while offline and genuinely unknown to the backend: retry the
    // same code so a link already sent to someone finally becomes valid.
    final retried = await _pushInvite(
      share: usableCache,
      senderName: senderName,
      senderEmail: senderEmail,
      senderImage: senderImage,
    );
    await localDataSource.cacheActiveShare(retried);
    return retried;
  }

  /// Sends the invitation to the backend, reporting whether it landed. A
  /// failure is not fatal: the code stays usable locally and is retried the
  /// next time the share screen opens.
  Future<FriendShareEntity> _pushInvite({
    required FriendShareEntity share,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  }) async {
    try {
      await remoteDataSource.createInvite(
        share: share,
        senderName: senderName,
        senderEmail: senderEmail,
        senderImage: senderImage,
      );
      return share.copyWith(isSynced: true);
    } catch (_) {
      return share.copyWith(isSynced: false);
    }
  }

  @override
  String? extractInviteCode(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final code =
          uri.queryParameters[AppConfig.inviteCodeQueryParam] ??
          uri.queryParameters['code'];
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
      throw MessageFailure(message: 'Sign in to reject this invitation.');
    }

    await remoteDataSource.rejectInvite(inviteCode, currentUserId);
  }

  @override
  Future<void> updateFriendProfile({
    required FriendsModel friend,
    required String username,
    required String image,
  }) async {
    final currentUserId = _currentUserId;
    if (friend.relationType != FriendConst.friend ||
        (currentUserId != null && friend.uid == currentUserId)) {
      throw MessageFailure(message: 'Unable to update this friend right now.');
    }

    try {
      final currentFriends = await Repository().get<FriendsModel>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where.exact('sid', friend.sid)]),
      );
      final currentFriend = currentFriends.isEmpty
          ? friend
          : currentFriends.first;

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

      await Repository().sqliteProvider.upsert<FriendsModel>(
        updatedFriend,
        repository: Repository(),
      );
      unawaited(
        Repository()
            .notifySubscriptionsWithLocalData<FriendsModel>()
            .catchError((_) {}),
      );
      unawaited(
        // ignore: body_might_complete_normally_catch_error
        Repository().upsert<FriendsModel>(updatedFriend).catchError((e) {
          debugPrint('Background friend update sync: $e');
        }),
      );
    } catch (_) {
      throw MessageFailure(message: 'Unable to update this friend right now.');
    }
  }

  @override
  Future<FriendUnlinkResult> unlinkFriend(FriendsModel friend) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw MessageFailure(message: 'Sign in to separate these accounts.');
    }

    final linkedUid = friend.uid;
    if (linkedUid == null || linkedUid.isEmpty) {
      throw MessageFailure(
        message: 'This profile is not linked to an account.',
      );
    }

    // The backend breaks both sides in one go; anything short of that would
    // leave a one-way link behind.
    final reported = await remoteDataSource.unlinkAccounts(friend.sid);
    final affectedSids = <String>{friend.sid, ...reported};

    try {
      for (final sid in affectedSids) {
        await _detachLocalFriendRow(sid, currentUserId);
      }
      await _purgeRecordsLostWithLink(affectedSids, currentUserId);
      unawaited(
        Repository()
            .notifySubscriptionsWithLocalData<FriendsModel>()
            .catchError((_) {}),
      );
      unawaited(
        Repository()
            .notifySubscriptionsWithLocalData<TransactionModel>()
            .catchError((_) {}),
      );
    } catch (error) {
      // The accounts are already separated server side; a local cleanup
      // hiccup must not be reported as a failed separation.
      debugPrint('Local cleanup after unlink: $error');
    }

    return FriendUnlinkResult(
      unlinkedSids: affectedSids.toList(),
      alreadyUnlinked: reported.isEmpty,
    );
  }

  /// A profile row this device could only see because of the link belongs to
  /// the other person: drop the local copy. A row we own simply loses its
  /// link and stays in the list with its history.
  Future<void> _detachLocalFriendRow(String sid, String currentUserId) async {
    final repository = Repository();
    final rows = await repository.get<FriendsModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('sid', sid)]),
    );
    if (rows.isEmpty) {
      return;
    }

    final row = rows.first;
    if (row.fid != currentUserId) {
      await repository.sqliteProvider.delete<FriendsModel>(
        row,
        repository: repository,
      );
      return;
    }

    if (row.uid == null || row.uid!.isEmpty) {
      return;
    }

    final detached = FriendsModel(
      sid: row.sid,
      uid: null,
      fid: row.fid,
      image: row.image,
      username: row.username,
      email: row.email,
      give: row.give,
      receive: row.receive,
      relationType: row.relationType,
      personalIncome: row.personalIncome,
      companyIncome: row.companyIncome,
    )..primaryKey = row.primaryKey;

    await repository.sqliteProvider.upsert<FriendsModel>(
      detached,
      repository: repository,
    );
  }

  /// Records that were only readable through the link. They stay untouched on
  /// the device that created them; here they would just linger as unreachable
  /// copies and skew the totals.
  Future<void> _purgeRecordsLostWithLink(
    Set<String> sids,
    String currentUserId,
  ) async {
    final repository = Repository();

    final transactions = await repository.get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    for (final transaction in transactions) {
      if (transaction.uid == currentUserId) {
        continue;
      }
      if (sids.contains(transaction.senderId) ||
          sids.contains(transaction.beneficiaryId)) {
        await repository.sqliteProvider.delete<TransactionModel>(
          transaction,
          repository: repository,
        );
      }
    }

    final debts = await repository.get<DebtModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    for (final debt in debts) {
      if (debt.createdBy == currentUserId) {
        continue;
      }
      if (sids.contains(debt.lenderId) || sids.contains(debt.borrowerId)) {
        await repository.sqliteProvider.delete<DebtModel>(
          debt,
          repository: repository,
        );
      }
    }
  }

  @override
  Future<FriendDeletionImpact> friendDeletionImpact(FriendsModel friend) async {
    final repository = Repository();
    final sid = friend.sid;

    final transactions = await repository.get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    final debts = await repository.get<DebtModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    final recurrings = await repository.get<RecurringTransfertModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );

    return FriendDeletionImpact(
      transactionCount: transactions
          .where((item) => item.senderId == sid || item.beneficiaryId == sid)
          .length,
      debtCount: debts
          .where((item) => item.lenderId == sid || item.borrowerId == sid)
          .length,
      recurringCount: recurrings
          .where((item) => item.senderId == sid || item.beneficiaryId == sid)
          .length,
    );
  }

  @override
  Future<void> deleteFriendWithHistory(FriendsModel friend) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw MessageFailure(message: 'Sign in to delete this profile.');
    }

    final linkedUid = friend.uid;
    if (linkedUid != null && linkedUid.isNotEmpty) {
      throw MessageFailure(
        message: 'Separate the two accounts before deleting this profile.',
      );
    }

    final repository = Repository();
    final sid = friend.sid;

    try {
      // Scheduled transfers first: leaving one behind would keep creating
      // entries for a profile that no longer exists.
      final recurrings = await repository.get<RecurringTransfertModel>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      for (final recurring in recurrings) {
        if (recurring.senderId == sid || recurring.beneficiaryId == sid) {
          await repository.delete<RecurringTransfertModel>(recurring);
        }
      }

      // Then the debts, which point at transactions we are about to remove.
      final debts = await repository.get<DebtModel>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      for (final debt in debts) {
        if (debt.lenderId == sid || debt.borrowerId == sid) {
          await repository.delete<DebtModel>(debt);
        }
      }

      final transactions = await repository.get<TransactionModel>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      for (final transaction in transactions) {
        if (transaction.senderId == sid || transaction.beneficiaryId == sid) {
          await repository.delete<TransactionModel>(transaction);
        }
      }

      final rows = await repository.get<FriendsModel>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where.exact('sid', sid)]),
      );
      await repository.delete<FriendsModel>(rows.isEmpty ? friend : rows.first);

      unawaited(
        Repository()
            .notifySubscriptionsWithLocalData<FriendsModel>()
            .catchError((_) {}),
      );
      unawaited(
        Repository()
            .notifySubscriptionsWithLocalData<TransactionModel>()
            .catchError((_) {}),
      );
    } on MessageFailure {
      rethrow;
    } catch (error) {
      debugPrint('Friend deletion failed: $error');
      throw MessageFailure(message: 'Unable to delete this profile right now.');
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
