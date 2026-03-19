import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
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
      final sender = transaction.sender;
      final gtid = const Uuid().v4();

      var senderId = sender.sid;
      if (senderId.isEmpty) {
        final senderResult = await localDataSource.createANewFriend(sender);
        senderId = await senderResult.fold(_throwFailure, (userModel) async {
          return userModel.sid;
        });
      }

      for (final split in resolvedSplits) {
        var beneficiaryId = split.beneficiary.sid;
        var image = split.beneficiary.image;

        if (beneficiaryId.isEmpty) {
          final friendResult = await localDataSource.createANewFriend(
            split.beneficiary,
          );

          beneficiaryId = await friendResult.fold(_throwFailure, (
            friend,
          ) async {
            return friend.sid;
          });
          image = await friendResult.fold(_throwFailure, (friend) async {
            return friend.image;
          });
        }

        final saveResult = await localDataSource.saveTransaction(
          gtid,
          title: transaction.name,
          date: transaction.date,
          amount: split.amount,
          currency: transaction.currency,
          note: transaction.note,
          senderId: senderId,
          beneficiaryId: beneficiaryId,
          image: image.isEmpty ? Constants.memojiDefault : image,
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

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }
}
