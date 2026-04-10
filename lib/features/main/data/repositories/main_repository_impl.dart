import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_datasource.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/domain/repositories/main_repository.dart';
import 'package:bicount/features/main/domain/services/main_finance_projection_service.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/failure.dart';

class MainRepositoryImpl implements MainRepository {
  MainRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource, {
    required this.currencyRepository,
    this.projectionService = const MainFinanceProjectionService(),
  });

  final MainLocalDataSource localDataSource;
  final MainRemoteDataSource remoteDataSource;
  final CurrencyRepositoryImpl currencyRepository;
  final MainFinanceProjectionService projectionService;

  @override
  Future<void> reconcileDeletedRecords() {
    return Repository().syncAllFromRemote();
  }

  @override
  Future<void> forceHydrate() {
    return localDataSource.forceHydrate();
  }

  @override
  Stream<MainEntity> getStartDataStream() {
    try {
      final userStream = localDataSource.getUserDetails();
      final friendsStream = localDataSource.getFriends();
      final transactionsStream = localDataSource.getTransaction();
      final recurringTransfertsStream = localDataSource
          .getRecurringTransferts();
      final connectionStateStream = remoteDataSource.connectionState();
      final currencyConfigStream = currencyRepository.watchConfig();

      return Rx.combineLatest6<
            UserModel,
            List<FriendsModel>,
            List<TransactionModel>,
            List<RecurringTransfertModel>,
            int,
            CurrencyConfigEntity,
            MainEntity
          >(
            userStream,
            friendsStream,
            transactionsStream,
            recurringTransfertsStream,
            connectionStateStream,
            currencyConfigStream,
            (
              user,
              friends,
              transactions,
              recurringTransferts,
              connectionState,
              currencyConfig,
            ) {
              return projectionService.project(
                user: user,
                friends: friends,
                transactions: transactions,
                recurringTransferts: recurringTransferts,
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
