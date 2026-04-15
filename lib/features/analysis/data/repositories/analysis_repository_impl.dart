import 'package:bicount/features/analysis/data/data_sources/local_datasource/analysis_local_datasource.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  AnalysisRepositoryImpl(
    this.localDataSource, {
    required this.currencyRepository,
    this.dashboardBuilder = const AnalysisDashboardBuilder(),
  });

  final AnalysisLocalDataSource localDataSource;
  final CurrencyRepositoryImpl currencyRepository;
  final AnalysisDashboardBuilder dashboardBuilder;

  @override
  Stream<AnalysisDashboardEntity> watchDashboard(AnalysisPeriod period) {
    return Rx.combineLatest2(
      localDataSource.watchTransactions(),
      currencyRepository.watchConfig(),
      (
        List<TransactionModel> transactions,
        CurrencyConfigEntity currencyConfig,
      ) {
        return dashboardBuilder.build(
          AnalysisSourceData(
            transactions: transactions,
            recurringTransferts: const [],
          ),
          period,
          currencyConfig,
        );
      },
    );
  }
}
