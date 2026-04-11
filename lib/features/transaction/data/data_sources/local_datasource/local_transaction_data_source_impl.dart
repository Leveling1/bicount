import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'local_transaction_friend_matcher.dart';
import 'local_transaction_friend_factory.dart';
import 'local_transaction_type_resolver.dart';
import '../../models/transaction.model.dart';

class LocalTransactionDataSourceImpl implements TransactionLocalDataSource {
  LocalTransactionDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
  }) : _currencyRepository = currencyRepository,
       _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService();

  final CurrencyRepositoryImpl _currencyRepository;
  final OfflineFinanceLocalService _offlineFinanceLocalService;
  final LocalTransactionFriendMatcher _friendMatcher =
      const LocalTransactionFriendMatcher();

  String? get _currentUid => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
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

      await Repository().upsert<FriendsModel>(friendAdd);
      return Right(friendAdd);
    } catch (_) {
      return _messageFailure('Unable to save this friend right now.');
    }
  }

  @override
  Future<Either<Failure, FriendsModel?>> findMatchingFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    try {
      final localFriends = await Repository().get<FriendsModel>(
        policy: OfflineFirstGetPolicy.localOnly,
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

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
    String? recurringTransfertId,
    int? generationMode,
  }) async {
    final uid = _currentUid;
    if (uid == null) {
      return _authenticationFailure();
    }

    try {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: amount,
        originalCurrencyCode: currency,
      );
      final type = resolveLocalTransactionType(
        ownerId: uid,
        senderId: senderId,
        beneficiaryId: beneficiaryId,
      );

      final transactionModel = TransactionModel(
        uid: uid,
        gtid: gtid,
        name: title,
        type: type,
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        date: date,
        note: note,
        amount: amount,
        currency: currency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        image: image,
        frequency: Frequency.oneTime,
        createdAt: DateTime.now().toIso8601String(),
        category: category,
        recurringTransfertId: recurringTransfertId,
        generationMode: generationMode ?? 0,
      );

      await Repository().upsert<TransactionModel>(transactionModel);
      await _offlineFinanceLocalService.applyTransactionEffects(
        currentUserId: uid,
        transaction: transactionModel,
      );
      return const Right(null);
    } catch (_) {
      return _messageFailure('The transaction could not be saved.');
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
  }) async {
    final currentUid = _currentUid;
    final ownerUid = previousTransaction.uid ?? currentUid;
    if (ownerUid == null) {
      return _authenticationFailure();
    }

    try {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: amount,
        originalCurrencyCode: currency,
      );
      final type = resolveLocalTransactionType(
        ownerId: ownerUid,
        senderId: senderId,
        beneficiaryId: beneficiaryId,
      );

      final transactionModel = TransactionModel(
        tid: previousTransaction.tid,
        uid: ownerUid,
        gtid: previousTransaction.gtid,
        name: title,
        type: type,
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        date: date,
        note: note,
        amount: amount,
        currency: currency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        image: image,
        frequency: previousTransaction.frequency,
        category: category,
        createdAt:
            previousTransaction.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      );

      await Repository().upsert<TransactionModel>(transactionModel);
      return const Right(null);
    } catch (_) {
      return _messageFailure('Unable to update this transaction right now.');
    }
  }

  Left<Failure, T> _authenticationFailure<T>() {
    return Left(AuthenticationFailure(message: 'Authentication failure'));
  }

  Left<Failure, T> _messageFailure<T>(String message) {
    return Left(MessageFailure(message: message));
  }
}
