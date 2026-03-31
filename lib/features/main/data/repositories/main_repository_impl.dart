import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/core/services/recurring_funding_local_service.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_datasource.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/domain/repositories/main_repository.dart';
import 'package:bicount/features/main/domain/services/main_finance_projection_service.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/failure.dart';

class MainRepositoryImpl implements MainRepository {
  MainRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource, {
    required this.currencyRepository,
    this.projectionService = const MainFinanceProjectionService(),
    RecurringFundingLocalService? recurringFundingLocalService,
  }) : recurringFundingLocalService =
           recurringFundingLocalService ??
           RecurringFundingLocalService(currencyRepository: currencyRepository);

  final MainLocalDataSource localDataSource;
  final MainRemoteDataSource remoteDataSource;
  final CurrencyRepositoryImpl currencyRepository;
  final MainFinanceProjectionService projectionService;
  final RecurringFundingLocalService recurringFundingLocalService;

  @override
  Future<void> reconcileDeletedRecords() {
    return Repository().syncAllFromRemote();
  }

  @override
  Future<void> processRecurringFundings() {
    return recurringFundingLocalService.syncDueRecurringFundings();
  }

  @override
  Stream<MainEntity> getStartDataStream() {
    try {
      final userStream = localDataSource.getUserDetails();
      final friendsStream = localDataSource.getFriends();
      final subscriptionsStream = localDataSource.getSubscriptions();
      final transactionsStream = localDataSource.getTransaction();
      final accountFundingsStream = localDataSource.getAccountFundings();
      final recurringFundingsStream = localDataSource.getRecurringFundings();
      final connectionStateStream = remoteDataSource.connectionState();
      final currencyConfigStream = currencyRepository.watchConfig();

      return Rx.combineLatest8<
            UserModel,
            List<FriendsModel>,
            List<SubscriptionModel>,
            List<TransactionModel>,
            List<AccountFundingModel>,
            List<RecurringFundingModel>,
            int,
            CurrencyConfigEntity,
            MainEntity
          >(
            userStream,
            friendsStream,
            subscriptionsStream,
            transactionsStream,
            accountFundingsStream,
            recurringFundingsStream,
            connectionStateStream,
            currencyConfigStream,
            (
              user,
              friends,
              subscriptions,
              transactions,
              accountFundings,
              recurringFundings,
              connectionState,
              currencyConfig,
            ) {
              return projectionService.project(
                user: user,
                friends: friends,
                subscriptions: subscriptions,
                transactions: transactions,
                accountFundings: accountFundings,
                recurringFundings: recurringFundings,
                connectionState: connectionState,
                currencyConfig: currencyConfig,
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
