import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/services/recurring_funding_local_service.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/salary/data/data_sources/local_datasource/salary_local_datasource.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:brick_offline_first/brick_offline_first.dart';

class LocalSalaryDataSourceImpl implements SalaryLocalDataSource {
  LocalSalaryDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
    RecurringFundingLocalService? recurringFundingLocalService,
  }) : _currencyRepository = currencyRepository,
       _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService(),
       _recurringFundingLocalService =
           recurringFundingLocalService ??
           RecurringFundingLocalService(currencyRepository: currencyRepository);

  final CurrencyRepositoryImpl _currencyRepository;
  final OfflineFinanceLocalService _offlineFinanceLocalService;
  final RecurringFundingLocalService _recurringFundingLocalService;

  @override
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence,
  ) async {
    final currentRecurringFunding = await _findRecurringFunding(
      occurrence.recurringFunding.recurringFundingId,
    );
    if (currentRecurringFunding == null) {
      throw Exception('Salary plan not found.');
    }

    final existingFunding = await _findFunding(occurrence.occurrenceId);
    if (existingFunding != null) {
      return;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: occurrence.amount,
      originalCurrencyCode: occurrence.currency,
    );
    final confirmedAt = DateTime.now().toIso8601String();
    final funding = AccountFundingModel(
      fundingId: occurrence.occurrenceId,
      sid: currentRecurringFunding.uid,
      amount: occurrence.amount,
      currency: occurrence.currency,
      referenceCurrencyCode: quote.referenceCurrencyCode,
      convertedAmount: quote.convertedAmount,
      amountCdf: quote.amountCdf,
      rateToCdf: quote.rateToCdf,
      fxRateDate: quote.fxRateDate,
      fxSnapshotId: quote.fxSnapshotId,
      category: Constants.personal,
      fundingType: AccountFundingType.salary,
      source: occurrence.source,
      note: occurrence.note,
      date: confirmedAt,
      createdAt: confirmedAt,
    );

    await Repository().upsert<AccountFundingModel>(funding);
    await _offlineFinanceLocalService.applyFundingEffects(funding);
  }

  @override
  Future<void> continueSalaryAutomatically(
    SalaryOccurrenceEntity occurrence,
  ) async {
    final currentRecurringFunding = await _findRecurringFunding(
      occurrence.recurringFunding.recurringFundingId,
    );
    if (currentRecurringFunding == null) {
      throw Exception('Salary plan not found.');
    }

    await Repository().upsert<RecurringFundingModel>(
      RecurringFundingModel(
        recurringFundingId: currentRecurringFunding.recurringFundingId,
        uid: currentRecurringFunding.uid,
        source: currentRecurringFunding.source,
        note: currentRecurringFunding.note,
        amount: currentRecurringFunding.amount,
        currency: currentRecurringFunding.currency,
        fundingType: currentRecurringFunding.fundingType,
        frequency: currentRecurringFunding.frequency,
        startDate: currentRecurringFunding.startDate,
        nextFundingDate: currentRecurringFunding.nextFundingDate,
        lastProcessedAt: currentRecurringFunding.lastProcessedAt,
        status: currentRecurringFunding.status,
        salaryProcessingMode: SalaryProcessingMode.automatic,
        salaryReminderStatus: SalaryReminderStatus.disabled,
        createdAt: currentRecurringFunding.createdAt,
      ),
    );

    if (!occurrence.isReceived) {
      await confirmSalaryOccurrence(occurrence);
    }

    await _recurringFundingLocalService.syncDueRecurringFundings(
      currentUserId: currentRecurringFunding.uid,
    );
  }

  Future<RecurringFundingModel?> _findRecurringFunding(
    String recurringFundingId,
  ) async {
    final items = await Repository().get<RecurringFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [Where.exact('recurringFundingId', recurringFundingId)],
      ),
    );
    return items.isEmpty ? null : items.first;
  }

  Future<AccountFundingModel?> _findFunding(String fundingId) async {
    final items = await Repository().get<AccountFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('fundingId', fundingId)]),
    );
    return items.isEmpty ? null : items.first;
  }
}
