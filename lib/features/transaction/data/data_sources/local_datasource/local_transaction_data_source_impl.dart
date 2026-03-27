import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction.model.dart';

class LocalTransactionDataSourceImpl implements TransactionLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  final OfflineFinanceLocalService _offlineFinanceLocalService =
      OfflineFinanceLocalService();

  String? get _currentUid => supabaseInstance.auth.currentUser?.id;

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
    FriendsModel friend,
  ) async {
    final id = const Uuid().v4();
    final uid = _currentUid;
    if (uid == null) {
      return Left(AuthenticationFailure(message: 'Authentication failure'));
    }

    try {
      final friendAdd = FriendsModel(
        uid: null,
        sid: id,
        fid: uid,
        username: friend.username,
        email: friend.email,
        image: friend.image.isEmpty ? Constants.memojiDefault : friend.image,
        give: 0.0,
        receive: 0.0,
        relationType: FriendConst.friend,
      );

      await Repository().upsert<FriendsModel>(friendAdd);
      return Right(friendAdd);
    } catch (_) {
      return Left(
        MessageFailure(message: 'Unable to save this friend right now.'),
      );
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
  }) async {
    final uid = _currentUid;
    if (uid == null) {
      return Left(AuthenticationFailure(message: 'Authentication failure'));
    }

    try {
      var type = TransactionTypes.othersCode;
      if (senderId == uid) {
        type = TransactionTypes.expenseCode;
      } else if (beneficiaryId == uid) {
        type = TransactionTypes.incomeCode;
      }

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
        image: image,
        frequency: Frequency.oneTime,
        createdAt: DateTime.now().toIso8601String(),
        category: category,
      );

      await Repository().upsert<TransactionModel>(transactionModel);
      await _offlineFinanceLocalService.applyTransactionEffects(
        currentUserId: uid,
        transaction: transactionModel,
      );
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(message: 'The transaction could not be saved.'),
      );
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
      return Left(AuthenticationFailure(message: 'Authentication failure'));
    }

    try {
      var type = TransactionTypes.othersCode;
      if (senderId == ownerUid) {
        type = TransactionTypes.expenseCode;
      } else if (beneficiaryId == ownerUid) {
        type = TransactionTypes.incomeCode;
      }

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
      return Left(
        MessageFailure(message: 'Unable to update this transaction right now.'),
      );
    }
  }

}
