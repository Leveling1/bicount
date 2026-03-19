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
  Future<FriendShareEntity?> getActiveShare() async => cachedShare;

  @override
  Future<List<FriendInviteEntity>> getCachedInvites() async => cachedInvites;
}

class _FakeFriendRemoteDataSource implements FriendRemoteDataSource {
  FriendShareEntity? createdShare;

  @override
  Future<void> acceptInvite(String inviteCode, String currentUserId) async {}

  @override
  Future<void> createInvite({
    required FriendShareEntity share,
    required String senderName,
    required String senderEmail,
    required String senderImage,
  }) async {
    createdShare = share;
  }

  @override
  Future<FriendInviteEntity?> getInviteByCode(String inviteCode) async => null;

  @override
  Future<void> rejectInvite(String inviteCode, String currentUserId) async {}

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
        'https://preview.bicount.app/friend/invite?code=abc123',
      ),
      'abc123',
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

    expect(share.inviteUrl, contains('/friend/invite?code='));
    expect(local.cachedShare?.inviteCode, share.inviteCode);
    expect(remote.createdShare?.inviteCode, share.inviteCode);
  });
}
