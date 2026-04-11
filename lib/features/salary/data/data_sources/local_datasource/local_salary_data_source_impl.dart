import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/data/data_sources/local_datasource/local_recurring_transfert_data_source_impl.dart';
import 'package:bicount/features/salary/data/data_sources/local_datasource/salary_local_datasource.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

class LocalSalaryDataSourceImpl implements SalaryLocalDataSource {
  LocalSalaryDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
  }) : _delegate = LocalRecurringTransfertDataSourceImpl(
         currencyRepository: currencyRepository,
         offlineFinanceLocalService: offlineFinanceLocalService,
       );

  final LocalRecurringTransfertDataSourceImpl _delegate;

  @override
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence,
  ) async {
    await _delegate.confirmSalaryOccurrence(
      occurrence,
      confirmedAmount: occurrence.amount,
    );
  }

  @override
  Future<void> continueSalaryAutomatically(
    SalaryOccurrenceEntity occurrence,
  ) async {
    await _delegate.confirmSalaryOccurrence(
      occurrence,
      confirmedAmount: occurrence.amount,
      switchToAutomatic: true,
    );
  }
}
