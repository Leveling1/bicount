import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/subscription/data/data_sources/local_datasource/subscription_local_datasource.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../brick/repository.dart';
import 'subscription_local_sync_helper.dart';

class LocalSubscriptionDataSourceImpl implements SubscriptionLocalDataSource {
  LocalSubscriptionDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
  }) : _currencyRepository = currencyRepository;

  final supabaseInstance = Supabase.instance.client;
  final CurrencyRepositoryImpl _currencyRepository;

  String? get _currentUid => supabaseInstance.auth.currentUser?.id;

  @override
  Future<Either<Failure, void>> addSubscription(
    SubscriptionEntity subscription,
  ) async {
    final uid = subscription.sid ?? _currentUid;
    if (uid == null) {
      return Left(AuthenticationFailure(message: 'Authentication failure'));
    }

    try {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: subscription.amount,
        originalCurrencyCode: subscription.currency,
      );
      final subscriptionAdd = SubscriptionModel(
        subscriptionId: subscription.subscriptionId ?? const Uuid().v4(),
        sid: uid,
        title: subscription.title,
        amount: subscription.amount,
        currency: subscription.currency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        frequency: subscription.frequency,
        startDate: subscription.startDate,
        nextBillingDate: subscription.nextBillingDate,
        notes: subscription.note,
        status: subscription.status,
        createdAt: subscription.createdAt,
        category: subscription.category,
      );

      await Repository().upsert<SubscriptionModel>(subscriptionAdd);
      // createSubscriptionWithEffects removed – subscription is now a transaction
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(message: 'Unable to save this subscription right now.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      final subscriptionId = subscription.subscriptionId;
      if (subscriptionId == null || subscriptionId.isEmpty) {
        return Left(
          MessageFailure(message: 'Subscription identifier is missing.'),
        );
      }

      final currentSubscription = await findSubscription(subscriptionId);
      if (currentSubscription == null) {
        return Left(MessageFailure(message: 'Subscription not found.'));
      }

      await deleteSubscriptionCompanions(
        currentUserId: currentSubscription.sid,
        subscriptionId: subscriptionId,
      );
      await Repository().delete<SubscriptionModel>(currentSubscription);
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(
          message: 'Unable to delete this subscription right now.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateSubscription(
    SubscriptionEntity subscription,
  ) async {
    final subscriptionId = subscription.subscriptionId;
    if (subscriptionId == null || subscriptionId.isEmpty) {
      return Left(
        MessageFailure(message: 'Subscription identifier is missing.'),
      );
    }

    try {
      final currentSubscription = await findSubscription(subscriptionId);
      if (currentSubscription == null) {
        return Left(MessageFailure(message: 'Subscription not found.'));
      }

      final quote = await _currencyRepository.resolveCreationQuote(
        amount: subscription.amount,
        originalCurrencyCode: subscription.currency,
      );
      final updatedSubscription = SubscriptionModel(
        subscriptionId: subscriptionId,
        sid: subscription.sid ?? currentSubscription.sid,
        title: subscription.title,
        amount: subscription.amount,
        currency: subscription.currency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        frequency: subscription.frequency,
        startDate: subscription.startDate,
        nextBillingDate: subscription.nextBillingDate,
        endDate: subscription.endDate,
        notes: subscription.note,
        status: SubscriptionConst.normalize(subscription.status),
        createdAt: currentSubscription.createdAt,
        category: subscription.category,
      );

      await Repository().upsert<SubscriptionModel>(updatedSubscription);
      await syncSubscriptionCompanions(
        currentUserId: updatedSubscription.sid,
        subscription: updatedSubscription,
      );
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(
          message: 'Unable to update this subscription right now.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribe(
    SubscriptionModel subscription,
  ) async {
    try {
      await Repository().upsert<SubscriptionModel>(
        SubscriptionModel(
          subscriptionId: subscription.subscriptionId,
          sid: subscription.sid,
          title: subscription.title,
          amount: subscription.amount,
          currency: subscription.currency,
          referenceCurrencyCode: subscription.referenceCurrencyCode,
          convertedAmount: subscription.convertedAmount,
          amountCdf: subscription.amountCdf,
          rateToCdf: subscription.rateToCdf,
          fxRateDate: subscription.fxRateDate,
          fxSnapshotId: subscription.fxSnapshotId,
          frequency: subscription.frequency,
          startDate: subscription.startDate,
          nextBillingDate: subscription.nextBillingDate,
          endDate: DateTime.now().toIso8601String(),
          notes: subscription.notes,
          createdAt: subscription.createdAt,
          category: subscription.category,
          status: SubscriptionConst.unsubscribed,
        ),
      );
      return const Right(null);
    } catch (_) {
      return Left(
        MessageFailure(
          message: 'Unable to update this subscription right now.',
        ),
      );
    }
  }
}
