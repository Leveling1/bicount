import 'package:bicount/features/friend/data/data_sources/local_datasource/friend_local_datasource.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/friend_remote_datasource.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFriendLocalDataSource implements FriendLocalDataSource {
  FriendShareEntity? cachedShare;
  List<FriendInviteEntity> cachedInvites = const [];

  @override
  Future<void> cacheActiveShare(FriendShareEntity share) async {
    cachedShare = share;
  }

  @override
  Future<void> cacheInvites(List<FriendInviteEntity> invites) async {
    cachedInvites = invites;
  }

  @override
  Future<FriendShareEntity?> getActiveShare({String? sourceFriendSid}) async {
    if (sourceFriendSid != null &&
        cachedShare?.sourceFriendSid != sourceFriendSid) {
      return null;
    }
    return cachedShare;
  }

  @override
  Future<void> clearActiveShare(String sourceFriendSid) async {
    if (cachedShare?.sourceFriendSid == sourceFriendSid) {
      cachedShare = null;
    }
  }

  @override
  Future<List<FriendInviteEntity>> getCachedInvites() async => cachedInvites;
}

class _FakeFriendRemoteDataSource implements FriendRemoteDataSource {
  FriendShareEntity? createdShare;
  int createInviteCalls = 0;
  bool createInviteThrows = false;
  List<String> unlinkedFriendSids = [];

  @override
  Future<void> acceptInvite(String inviteCode, String currentUserId) async {}

  @override
  Future<void> createInvite({
    required FriendShareEntity share,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  }) async {
    createInviteCalls += 1;
    if (createInviteThrows) {
      throw Exception('offline');
    }
    createdShare = share;
  }

  @override
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode) async => null;

  @override
  Future<void> rejectInvite(String inviteCode, String currentUserId) async {}

  @override
  Future<FriendInviteEntity?> findReusableInvite({
    required String sourceFriendSid,
    required String currentUserId,
  }) async => null;

  @override
  Future<List<String>> unlinkAccounts(String friendSid) async {
    unlinkedFriendSids.add(friendSid);
    return [friendSid];
  }

  @override
  Future<void> cancelPendingInvites({
    required String sourceFriendSid,
    required String currentUserId,
  }) async {
    cancelledInviteSids.add(sourceFriendSid);
  }

  List<String> cancelledInviteSids = [];

  @override
  Stream<List<FriendInviteEntity>> watchInvites(String currentUserId) {
    return const Stream.empty();
  }
}

void main() {
  test('friend repository extracts invite code from deep link', () {
    final repository = FriendRepositoryImpl(
      localDataSource: _FakeFriendLocalDataSource(),
      remoteDataSource: _FakeFriendRemoteDataSource(),
    );

    expect(
      repository.extractInviteCode(
        'https://bicount.youngsolver.org/friend/invite?inviteCode=abc123',
      ),
      'abc123',
    );
    expect(
      repository.extractInviteCode(
        'https://bicount.youngsolver.org/friend/invite?code=legacy123',
      ),
      'legacy123',
    );
    expect(repository.extractInviteCode(' invite-code '), 'invite-code');
    expect(repository.extractInviteCode(''), isNull);
  });

  test('friend repository creates and caches share link', () async {
    final local = _FakeFriendLocalDataSource();
    final remote = _FakeFriendRemoteDataSource();
    final repository = FriendRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );

    final share = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: '',
      sourceFriendName: '',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );

    expect(share.inviteUrl, contains('/friend/invite?inviteCode='));
    expect(local.cachedShare?.inviteCode, share.inviteCode);
    expect(remote.createdShare?.inviteCode, share.inviteCode);
    expect(share.isSynced, isTrue);
  });

  test('opening the share screen again reuses the same code', () async {
    final local = _FakeFriendLocalDataSource();
    final remote = _FakeFriendRemoteDataSource();
    final repository = FriendRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );

    final first = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );
    final second = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );

    expect(second.inviteCode, first.inviteCode);
    expect(remote.createInviteCalls, 1);
  });

  test('asking for a new code replaces the previous one', () async {
    final local = _FakeFriendLocalDataSource();
    final remote = _FakeFriendRemoteDataSource();
    final repository = FriendRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );

    final first = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );
    final refreshed = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
      forceNew: true,
    );

    expect(refreshed.inviteCode, isNot(first.inviteCode));
    expect(remote.createInviteCalls, 2);
  });

  test('a code created offline is flagged, then retried once back', () async {
    final local = _FakeFriendLocalDataSource();
    final remote = _FakeFriendRemoteDataSource()..createInviteThrows = true;
    final repository = FriendRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );

    final offline = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );

    expect(offline.isSynced, isFalse);
    expect(local.cachedShare?.isSynced, isFalse);

    remote.createInviteThrows = false;
    final recovered = await repository.createInvite(
      senderName: 'youngsolver',
      senderEmail: 'youngsolver@example.com',
      senderImage: '',
      sourceFriendSid: 'friend-1',
      sourceFriendName: 'Ada',
      sourceFriendEmail: '',
      sourceFriendImage: '',
    );

    // Same code, so a link already sent to someone finally works.
    expect(recovered.inviteCode, offline.inviteCode);
    expect(recovered.isSynced, isTrue);
    expect(remote.createInviteCalls, 2);
  });
}
