import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:dartz/dartz.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../models/transaction.model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(
    this.localDataSource, {
    this.splitResolver = const TransactionSplitResolver(),
    Future<void> Function(RecurringTransfertModel recurringTransfert)?
    saveRecurringTransfert,
  }) : _saveRecurringTransfert =
           saveRecurringTransfert ??
           OfflineFinanceLocalService().createRecurringTransfert;

  final TransactionLocalDataSource localDataSource;
  final TransactionSplitResolver splitResolver;
  final Future<void> Function(RecurringTransfertModel recurringTransfert)
  _saveRecurringTransfert;

  @override
  Future<void> createTransaction(
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _ensureParty(
        transaction.sender,
        resolvedParties: resolvedParties,
      );
      final gtid = const Uuid().v4();

      // Create a recurring template if the user enabled recurring mode.
      String? recurringTransfertId;
      int? generationMode;
      if (transaction.isRecurring &&
          transaction.recurringFrequency != null &&
          transaction.recurringTypeId != null) {
        final firstBeneficiary = await _ensureParty(
          resolvedSplits.first.beneficiary,
          resolvedParties: resolvedParties,
        );
        recurringTransfertId = const Uuid().v4();
        generationMode = 1; // manualConfirmation

        await _saveRecurringTransfert(
          RecurringTransfertModel(
            recurringTransfertId: recurringTransfertId,
            uid: sender.sid,
            recurringTransfertTypeId: transaction.recurringTypeId!,
            title: transaction.name,
            note: transaction.note,
            amount: transaction.totalAmount,
            currency: transaction.currency,
            senderId: sender.sid,
            beneficiaryId: firstBeneficiary.sid,
            frequency: transaction.recurringFrequency!,
            startDate: transaction.date,
            nextDueDate: transaction.date,
          ),
        );
      }

      for (final split in resolvedSplits) {
        final beneficiary = await _ensureParty(
          split.beneficiary,
          resolvedParties: resolvedParties,
        );
        await _unwrapEither(
          await localDataSource.saveTransaction(
            gtid,
            title: transaction.name,
            date: transaction.date,
            amount: split.amount,
            category: transaction.category,
            currency: transaction.currency,
            note: transaction.note,
            senderId: sender.sid,
            beneficiaryId: beneficiary.sid,
            image: beneficiary.image.isEmpty
                ? Constants.memojiDefault
                : beneficiary.image,
            recurringTransfertId: recurringTransfertId,
            generationMode: generationMode,
          ),
        );
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) async {
    try {
      final currentTransactions = await Repository().get<TransactionModel>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where.exact('tid', transaction.tid)]),
      );

      if (currentTransactions.isEmpty) {
        throw MessageFailure(
          message: 'Unable to delete this transaction right now.',
        );
      }

      await Repository().delete<TransactionModel>(currentTransactions.first);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to delete this transaction right now.',
      );
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

      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _ensureParty(
        transaction.sender,
        resolvedParties: resolvedParties,
      );
      final split = resolvedSplits.single;
      final beneficiary = await _ensureParty(
        split.beneficiary,
        resolvedParties: resolvedParties,
      );
      await _unwrapEither(
        await localDataSource.updateTransaction(
          previousTransaction,
          title: transaction.name,
          date: transaction.date,
          amount: split.amount,
          category: transaction.category,
          currency: transaction.currency,
          note: transaction.note,
          senderId: sender.sid,
          beneficiaryId: beneficiary.sid,
          image: beneficiary.image.isEmpty
              ? Constants.memojiDefault
              : beneficiary.image,
        ),
      );
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<_ResolvedParty> _ensureParty(
    FriendsModel party, {
    required Map<String, _ResolvedParty> resolvedParties,
  }) async {
    final directPartyId = _resolvePartyId(party);
    final partyImage = party.image.isEmpty
        ? Constants.memojiDefault
        : party.image;

    if (directPartyId.isNotEmpty) {
      final resolvedParty = _ResolvedParty(
        sid: directPartyId,
        image: partyImage,
      );
      resolvedParties[_partyCacheKey(party)] = resolvedParty;
      return resolvedParty;
    }

    final cacheKey = _partyCacheKey(party);
    final cachedParty = resolvedParties[cacheKey];
    if (cachedParty != null) {
      return cachedParty;
    }

    final existingFriend = await _unwrapEither(
      await localDataSource.findMatchingFriend(party),
    );
    if (existingFriend != null) {
      final resolvedParty = _ResolvedParty(
        sid: existingFriend.sid,
        image: existingFriend.image.isEmpty ? partyImage : existingFriend.image,
      );
      resolvedParties[cacheKey] = resolvedParty;
      return resolvedParty;
    }

    final createdFriend = await _unwrapEither(
      await localDataSource.createANewFriend(party),
    );
    final resolvedParty = _ResolvedParty(
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

  String _partyCacheKey(FriendsModel party) {
    if (party.sid.isNotEmpty) {
      return 'sid:${party.sid}';
    }

    final uid = party.uid;
    if (uid != null && uid.isNotEmpty) {
      return 'uid:$uid';
    }

    return 'draft:${party.relationType}:${_normalizePartyLookupValue(party.username)}:${_normalizePartyLookupValue(party.email)}';
  }

  String _normalizePartyLookupValue(String value) {
    return value.trim().toLowerCase();
  }
}

class _ResolvedParty {
  const _ResolvedParty({required this.sid, required this.image});

  final String sid;
  final String image;
}
