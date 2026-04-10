import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/services/recurring_funding_local_service.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/add_fund/data/data_sources/local_datasource/add_fund_local_datasource.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class LocalAddFundDataSourceImpl implements AddFundLocalDataSource {
  LocalAddFundDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
    RecurringFundingLocalService? recurringFundingLocalService,
    RecurringFundingScheduleService? scheduleService,
  }) : _currencyRepository = currencyRepository,
       _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService(),
       _recurringFundingLocalService =
           recurringFundingLocalService ??
           RecurringFundingLocalService(currencyRepository: currencyRepository),
       _scheduleService =
           scheduleService ?? const RecurringFundingScheduleService();

  final supabaseInstance = Supabase.instance.client;
  final CurrencyRepositoryImpl _currencyRepository;
  // ignore: unused_field
  final OfflineFinanceLocalService _offlineFinanceLocalService;
  final RecurringFundingLocalService _recurringFundingLocalService;
  final RecurringFundingScheduleService _scheduleService;

  String? get _currentUid => supabaseInstance.auth.currentUser?.id;

  @override
  Future<void> addAccountFunding(AddAccountFundingEntity data) async {
    final sid = data.sid ?? _currentUid;
    if (sid == null) {
      throw Exception('Authentication failure');
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: data.amount,
      originalCurrencyCode: data.currency,
    );
    final accountFundingData = AccountFundingModel(
      fundingId: const Uuid().v4(),
      sid: sid,
      source: data.source,
      note: data.note,
      amount: data.amount,
      currency: data.currency,
      referenceCurrencyCode: quote.referenceCurrencyCode,
      convertedAmount: quote.convertedAmount,
      amountCdf: quote.amountCdf,
      rateToCdf: quote.rateToCdf,
      fxRateDate: quote.fxRateDate,
      fxSnapshotId: quote.fxSnapshotId,
      fundingType: data.fundingType,
      category: data.category,
      date: _scheduleService.normalizeDate(data.date),
    );

    if (data.isRecurring) {
      final frequency = data.frequency;
      if (frequency == null) {
        throw Exception('Recurring frequency is required.');
      }

      await _recurringFundingLocalService.createRecurringFunding(
        RecurringFundingModel(
          uid: sid,
          source: data.source,
          note: data.note,
          amount: data.amount,
          currency: data.currency,
          fundingType: data.fundingType,
          frequency: frequency,
          startDate: accountFundingData.date,
          nextFundingDate: accountFundingData.date,
          salaryProcessingMode: data.salaryProcessingMode,
          salaryReminderStatus: data.salaryReminderStatus,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      return;
    }

    await Repository().upsert<AccountFundingModel>(accountFundingData);
    // applyFundingEffects removed – add_fund is superseded by transaction + recurring_transfert
  }

  @override
  Future<void> deleteAccountFunding(AccountFundingModel funding) async {
    final currentFunding = await _findFunding(funding.fundingId);
    if (currentFunding == null) {
      throw Exception('Account funding not found.');
    }

    await Repository().delete<AccountFundingModel>(currentFunding);
  }

  @override
  Future<void> updateAccountFunding(AddAccountFundingEntity data) async {
    final fundingId = data.fundingId;
    if (fundingId == null || fundingId.isEmpty) {
      throw Exception('Account funding identifier is missing.');
    }

    final currentFunding = await _findFunding(fundingId);
    if (currentFunding == null) {
      throw Exception('Account funding not found.');
    }

    final normalizedDate = _scheduleService.normalizeDate(data.date);
    final quote = await _currencyRepository.resolveCreationQuote(
      amount: data.amount,
      originalCurrencyCode: data.currency,
    );
    final updatedFunding = AccountFundingModel(
      fundingId: fundingId,
      sid: data.sid ?? currentFunding.sid,
      source: data.source,
      note: data.note,
      amount: data.amount,
      currency: data.currency,
      referenceCurrencyCode: quote.referenceCurrencyCode,
      convertedAmount: quote.convertedAmount,
      amountCdf: quote.amountCdf,
      rateToCdf: quote.rateToCdf,
      fxRateDate: quote.fxRateDate,
      fxSnapshotId: quote.fxSnapshotId,
      fundingType: data.fundingType,
      category: data.category,
      date: normalizedDate,
      createdAt: currentFunding.createdAt,
    );

    await Repository().upsert<AccountFundingModel>(updatedFunding);
  }

  Future<AccountFundingModel?> _findFunding(String fundingId) async {
    final items = await Repository().get<AccountFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('fundingId', fundingId)]),
    );
    return items.isEmpty ? null : items.first;
  }
}
