import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/subscription/data/data_sources/local_datasource/subscription_local_datasource.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:bicount/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required this.localDataSource});

  final SubscriptionLocalDataSource localDataSource;

  @override
  Future<void> addSubscription(SubscriptionEntity subscription) async {
    try {
      final result = await localDataSource.addSubscription(subscription);
      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to save this subscription right now.',
      );
    }
  }

  @override
  Future<void> unsubscribe(SubscriptionModel subscription) async {
    try {
      final result = await localDataSource.unsubscribe(subscription);
      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to update this subscription right now.',
      );
    }
  }

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }
}
