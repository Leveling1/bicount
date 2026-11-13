part of 'local_transaction_data_source_impl.dart';

extension on LocalTransactionDataSourceImpl {
  Future<Either<Failure, FriendsModel>> _createFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    final id = const Uuid().v4();
    final uid = _currentUid;
    if (uid == null) {
      return _authenticationFailure();
    }

    try {
      final friendAdd = buildTransactionPlaceholderFriend(
        sid: id,
        ownerUid: uid,
        friend: friend,
        transactionType: transactionType,
      );

      await Repository().upsert<FriendsModel>(friendAdd, isCreation: true);

      return Right(friendAdd);
    } catch (_) {
      return _messageFailure('Unable to save this friend right now.');
    }
  }

  Future<Either<Failure, FriendsModel?>> _findFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    try {
      final localFriends = await Repository().get<FriendsModel>(
        policy: OfflineReadPolicy.localOnly,
      );
      return Right(
        _friendMatcher.findMatch(
          localFriends,
          friend,
          transactionType: transactionType,
        ),
      );
    } catch (_) {
      return _messageFailure('Unable to load this friend right now.');
    }
  }
}
