import 'package:bicount/features/graph/data/data_sources/local_datasource/graph_local_datasource.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/repositories/graph_repository.dart';
import 'package:bicount/features/graph/domain/services/graph_dashboard_builder.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../subscription/data/models/subscription.model.dart';

class GraphRepositoryImpl implements GraphRepository {
  GraphRepositoryImpl(
    this.localDataSource, {
    required this.currencyRepository,
    this.dashboardBuilder = const GraphDashboardBuilder(),
  });

  final GraphLocalDataSource localDataSource;
  final CurrencyRepositoryImpl currencyRepository;
  final GraphDashboardBuilder dashboardBuilder;

  @override
  Stream<GraphDashboardEntity> watchDashboard(GraphPeriod period) {
    return Rx.combineLatest4(
      localDataSource.watchTransactions(),
      localDataSource.watchSubscriptions(),
      localDataSource.watchAccountFundings(),
      currencyRepository.watchConfig(),
      (
        List<TransactionModel> transactions,
        List<SubscriptionModel> subscriptions,
        List<AccountFundingModel> fundings,
        CurrencyConfigEntity currencyConfig,
      ) {
        return dashboardBuilder.build(
          GraphSourceData(
            transactions: transactions,
            subscriptions: subscriptions,
            fundings: fundings,
          ),
          period,
          currencyConfig,
        );
      },
    );
  }
}
