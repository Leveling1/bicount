import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

class TransactionPartyResolutionService {
  TransactionPartyResolutionService(this.localDataSource);

  final TransactionLocalDataSource localDataSource;

  Future<ResolvedTransactionParty> resolveParty(
    FriendsModel party, {
    required int transactionType,
    required Map<String, ResolvedTransactionParty> resolvedParties,
  }) async {
    final directPartyId = _resolvePartyId(party);
    final partyImage = party.image.isEmpty
        ? Constants.memojiDefault
        : party.image;

    if (directPartyId.isNotEmpty) {
      final resolvedParty = ResolvedTransactionParty(
        sid: directPartyId,
        image: partyImage,
      );
      resolvedParties[_partyCacheKey(party, transactionType: transactionType)] =
          resolvedParty;
      return resolvedParty;
    }

    final cacheKey = _partyCacheKey(party, transactionType: transactionType);
    final cachedParty = resolvedParties[cacheKey];
    if (cachedParty != null) {
      return cachedParty;
    }

    final existingFriend = await _unwrapEither(
      await localDataSource.findMatchingFriend(
        party,
        transactionType: transactionType,
      ),
    );
    if (existingFriend != null) {
      final resolvedParty = ResolvedTransactionParty(
        sid: existingFriend.sid,
        image: existingFriend.image.isEmpty ? partyImage : existingFriend.image,
      );
      resolvedParties[cacheKey] = resolvedParty;
      return resolvedParty;
    }

    final createdFriend = await _unwrapEither(
      await localDataSource.createANewFriend(
        party,
        transactionType: transactionType,
      ),
    );
    final resolvedParty = ResolvedTransactionParty(
      sid: createdFriend.sid,
      image: createdFriend.image.isEmpty ? partyImage : createdFriend.image,
    );
    resolvedParties[cacheKey] = resolvedParty;
    return resolvedParty;
  }

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }

  Future<T> _unwrapEither<T>(Either<Failure, T> result) async {
    return result.fold(_throwFailure, (value) async => value);
  }

  String _resolvePartyId(FriendsModel party) {
    if (party.sid.isNotEmpty) {
      return party.sid;
    }

    final uid = party.uid;
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }

    return '';
  }

  String _partyCacheKey(FriendsModel party, {required int transactionType}) {
    if (party.sid.isNotEmpty) {
      return 'sid:${party.sid}';
    }

    final uid = party.uid;
    if (uid != null && uid.isNotEmpty) {
      return 'uid:$uid';
    }

    final relationType = FriendConst.getTypeOfFriend(transactionType);
    return 'draft:$relationType:${_normalize(party.username)}:${_normalize(party.email)}';
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class ResolvedTransactionParty {
  const ResolvedTransactionParty({required this.sid, required this.image});

  final String sid;
  final String image;
}
