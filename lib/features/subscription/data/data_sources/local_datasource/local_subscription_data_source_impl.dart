import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/features/subscription/data/data_sources/local_datasource/subscription_local_datasource.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../brick/repository.dart';

class LocalSubscriptionDataSourceImpl implements SubscriptionLocalDataSource {
  LocalSubscriptionDataSourceImpl({
    OfflineFinanceLocalService? offlineFinanceLocalService,
  }) : _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService();

  final supabaseInstance = Supabase.instance.client;
  final OfflineFinanceLocalService _offlineFinanceLocalService;

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
      final subscriptionAdd = SubscriptionModel(
        subscriptionId: const Uuid().v4(),
        sid: uid,
        title: subscription.title,
        amount: subscription.amount,
        currency: subscription.currency,
        frequency: subscription.frequency,
        startDate: subscription.startDate,
        nextBillingDate: subscription.nextBillingDate,
        notes: subscription.note,
        status: subscription.status,
        createdAt: subscription.createdAt,
        category: subscription.category,
      );

      await _offlineFinanceLocalService.createSubscriptionWithEffects(
        currentUserId: uid,
        subscription: subscriptionAdd,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        MessageFailure(message: 'Unable to save this subscription right now.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribe(
    SubscriptionModel subscription,
  ) async {
    try {
      await Repository().upsert<SubscriptionModel>(subscription);
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
