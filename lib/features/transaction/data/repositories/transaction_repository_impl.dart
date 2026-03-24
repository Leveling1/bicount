import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(
    this.localDataSource, {
    this.splitResolver = const TransactionSplitResolver(),
  });

  final TransactionLocalDataSource localDataSource;
  final TransactionSplitResolver splitResolver;

  @override
  Future<void> createTransaction(
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      final sender = await _ensureParty(transaction.sender);
      final gtid = const Uuid().v4();

      for (final split in resolvedSplits) {
        final beneficiary = await _ensureParty(split.beneficiary);
        final saveResult = await localDataSource.saveTransaction(
          gtid,
          title: transaction.name,
          date: transaction.date,
          amount: split.amount,
          category: transaction.category,
          currency: transaction.currency,
          note: transaction.note,
          senderId: sender.id,
          beneficiaryId: beneficiary.id,
          image: beneficiary.image.isEmpty
              ? Constants.memojiDefault
              : beneficiary.image,
        );

        await saveResult.fold(_throwFailure, (_) async => null);
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  @override
  Future<void> updateTransaction(
    TransactionEntity previousTransaction,
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      if (resolvedSplits.length != 1) {
        throw MessageFailure(
          message: 'Edit this transaction with one beneficiary only.',
        );
      }

      final sender = await _ensureParty(transaction.sender);
      final split = resolvedSplits.single;
      final beneficiary = await _ensureParty(split.beneficiary);
      final result = await localDataSource.updateTransaction(
        previousTransaction,
        title: transaction.name,
        date: transaction.date,
        amount: split.amount,
        category: transaction.category,
        currency: transaction.currency,
        note: transaction.note,
        senderId: sender.id,
        beneficiaryId: beneficiary.id,
        image: beneficiary.image.isEmpty
            ? Constants.memojiDefault
            : beneficiary.image,
      );

      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  @override
  Future<void> addSubscription(SubscriptionEntity subscription) async {
    try {
      final result = await localDataSource.addSubscription(subscription);
      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  @override
  Future<void> unsubscribe(SubscriptionModel subscription) async {
    try {
      final subscriptionModel = SubscriptionModel(
        subscriptionId: subscription.subscriptionId,
        title: subscription.title,
        amount: subscription.amount,
        currency: subscription.currency,
        frequency: subscription.frequency,
        nextBillingDate: subscription.nextBillingDate,
        category: subscription.category,
        createdAt: subscription.createdAt,
        sid: subscription.sid,
        startDate: subscription.startDate,
        notes: subscription.notes,
        endDate: DateTime.now().toIso8601String(),
        status: SubscriptionConst.unsubscribed,
      );
      final result = await localDataSource.unsubscribe(subscriptionModel);
      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<_ResolvedParty> _ensureParty(FriendsModel party) async {
    var partyId = _resolvePartyId(party);
    var image = party.image;

    if (partyId.isEmpty) {
      final result = await localDataSource.createANewFriend(party);
      partyId = await result.fold(_throwFailure, (friend) async => friend.sid);
      image = await result.fold(_throwFailure, (friend) async => friend.image);
    }

    return _ResolvedParty(id: partyId, image: image);
  }

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
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
}

class _ResolvedParty {
  const _ResolvedParty({required this.id, required this.image});

  final String id;
  final String image;
}
