import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_datasource.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/domain/repositories/main_repository.dart';
import 'package:bicount/features/main/domain/services/main_finance_projection_service.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/failure.dart';

class MainRepositoryImpl implements MainRepository {
  MainRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource, {
    this.projectionService = const MainFinanceProjectionService(),
  });

  final MainLocalDataSource localDataSource;
  final MainRemoteDataSource remoteDataSource;
  final MainFinanceProjectionService projectionService;

  @override
  Future<void> reconcileDeletedRecords() {
    return Repository().syncAllFromRemote();
  }

  @override
  Stream<MainEntity> getStartDataStream() {
    try {
      final userStream = localDataSource.getUserDetails();
      final friendsStream = localDataSource.getFriends();
      final subscriptionsStream = localDataSource.getSubscriptions();
      final transactionsStream = localDataSource.getTransaction();
      final accountFundingsStream = localDataSource.getAccountFundings();
      final connectionStateStream = remoteDataSource.connectionState();

      return Rx.combineLatest6<
            UserModel,
            List<FriendsModel>,
            List<SubscriptionModel>,
            List<TransactionModel>,
            List<AccountFundingModel>,
            int,
            MainEntity
          >(
            userStream,
            friendsStream,
            subscriptionsStream,
            transactionsStream,
            accountFundingsStream,
            connectionStateStream,
            (
              user,
              friends,
              subscriptions,
              transactions,
              accountFundings,
              connectionState,
            ) {
              return projectionService.project(
                user: user,
                friends: friends,
                subscriptions: subscriptions,
                transactions: transactions,
                accountFundings: accountFundings,
                connectionState: connectionState,
              );
            },
          )
          .handleError((error, stackTrace) {
            throw MessageFailure(
              message: 'Error combining startup data: ${error.toString()}',
            );
          });
    } catch (e) {
      return Stream.error(MessageFailure(message: e.toString()));
    }
  }
}
