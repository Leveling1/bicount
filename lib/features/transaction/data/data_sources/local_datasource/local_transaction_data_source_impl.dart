import 'package:bicount/core/offline/offline_model.dart';

import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_quote_entity.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'local_transaction_friend_matcher.dart';
import 'local_transaction_friend_factory.dart';
import '../../models/transaction.model.dart';

part 'local_transaction_update_helpers.dart';
part 'local_transaction_update.dart';
part 'local_transaction_parties.dart';

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
  }) => _createFriend(friend, transactionType: transactionType);

  @override
  Future<Either<Failure, FriendsModel?>> findMatchingFriend(
    FriendsModel friend, {
    required int transactionType,
  }) => _findFriend(friend, transactionType: transactionType);

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    String? transactionId,
    required String title,
    required int type,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    String? senderWalletId,
    String? beneficiaryWalletId,
    required String beneficiaryId,
    required String image,
    String? originId,
    String? originOccurrenceDate,
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

      final transactionModel = TransactionModel(
        tid: transactionId,
        uid: uid,
        gtid: gtid,
        name: title,
        type: type,
        beneficiaryId: beneficiaryId,
        senderId: senderId,
        senderWalletId: senderWalletId,
        beneficiaryWalletId: beneficiaryWalletId,
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
        originId: originId,
        originOccurrenceDate: originOccurrenceDate,
        recurringTransfertId:
            TransactionTypes.expenseTypes.contains(type) ||
                TransactionTypes.incomeTypes.contains(type)
            ? originId
            : null,
        recurringOccurrenceDate:
            TransactionTypes.expenseTypes.contains(type) ||
                TransactionTypes.incomeTypes.contains(type)
            ? originOccurrenceDate
            : null,
        generationMode: generationMode ?? 0,
      );

      await Repository().upsert<TransactionModel>(
        transactionModel,
        isCreation: true,
      );

      // Apply finance effects locally so balances update immediately.
      await _offlineFinanceLocalService.applyTransactionEffects(
        currentUserId: uid,
        transaction: transactionModel,
      );

      return const Right(null);
    } on Failure catch (error) {
      return Left(error);
    } catch (_) {
      return _messageFailure('The transaction could not be saved.');
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required int type,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    String? senderWalletId,
    String? beneficiaryWalletId,
    required String beneficiaryId,
    required String image,
    int? frequency,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) => _updateTransaction(
    previousTransaction,
    title: title,
    type: type,
    date: date,
    amount: amount,
    category: category,
    currency: currency,
    note: note,
    senderId: senderId,
    senderWalletId: senderWalletId,
    beneficiaryWalletId: beneficiaryWalletId,
    beneficiaryId: beneficiaryId,
    image: image,
    frequency: frequency,
    originId: originId,
    originOccurrenceDate: originOccurrenceDate,
    generationMode: generationMode,
  );

  Left<Failure, T> _authenticationFailure<T>() {
    return Left(AuthenticationFailure(message: 'Authentication failure'));
  }

  Left<Failure, T> _messageFailure<T>(String message) {
    return Left(MessageFailure(message: message));
  }
}
