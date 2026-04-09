import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
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
    RecurringFundingScheduleService scheduleService =
        const RecurringFundingScheduleService(),
  }) : _currencyRepository = currencyRepository,
       _scheduleService = scheduleService;

  final CurrencyRepositoryImpl _currencyRepository;
  final RecurringFundingScheduleService _scheduleService;

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

    final existingFunding = await _findFundingForOccurrence(
      recurringFunding: currentRecurringFunding,
      occurrence: occurrence,
    );
    if (existingFunding != null) {
      return;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: occurrence.amount,
      originalCurrencyCode: occurrence.currency,
    );
    final confirmedAt = _scheduleService
        .mergeDateWithCurrentTime(occurrence.expectedDate)
        .toIso8601String();
    final funding = AccountFundingModel(
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
      fundingType: currentRecurringFunding.fundingType,
      source: occurrence.source,
      note: occurrence.note,
      date: confirmedAt,
      createdAt: DateTime.now().toIso8601String(),
    );

    await Repository().upsert<AccountFundingModel>(funding);
    // applyFundingEffects removed – salary is superseded by recurring_transfert
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

  Future<AccountFundingModel?> _findFundingForOccurrence({
    required RecurringFundingModel recurringFunding,
    required SalaryOccurrenceEntity occurrence,
  }) async {
    final items = await Repository().get<AccountFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [
          Where.exact('sid', recurringFunding.uid),
          Where.exact('source', occurrence.source),
          Where.exact('fundingType', recurringFunding.fundingType),
        ],
      ),
    );

    final expectedKey = _scheduleService.occurrenceMatchKey(
      ownerUid: recurringFunding.uid,
      source: occurrence.source,
      fundingType: recurringFunding.fundingType,
      amount: occurrence.amount,
      currency: occurrence.currency,
      expectedDate: occurrence.expectedDate,
    );

    for (final item in items) {
      final itemDate = _scheduleService.parseDate(item.date);
      if (itemDate == null) {
        continue;
      }
      final itemKey = _scheduleService.occurrenceMatchKey(
        ownerUid: item.sid,
        source: item.source,
        fundingType: item.fundingType,
        amount: item.amount,
        currency: item.currency,
        expectedDate: itemDate,
      );
      if (itemKey == expectedKey) {
        return item;
      }
    }

    return null;
  }
}
