import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/data/data_sources/local_datasource/recurring_transfert_local_datasource.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/update_recurring_transfert_request_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class LocalRecurringTransfertDataSourceImpl
    implements RecurringTransfertLocalDataSource {
  LocalRecurringTransfertDataSourceImpl({
    required CurrencyRepositoryImpl currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
    RecurringFundingScheduleService scheduleService =
        const RecurringFundingScheduleService(),
  }) : _currencyRepository = currencyRepository,
       _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService(),
       _scheduleService = scheduleService;

  final CurrencyRepositoryImpl _currencyRepository;
  final OfflineFinanceLocalService _offlineFinanceLocalService;
  final RecurringFundingScheduleService _scheduleService;

  String? get _currentUid => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<void> updateRecurringTransfert(
    UpdateRecurringTransfertRequestEntity request,
  ) async {
    final current = await _findRecurringTransfert(request.recurringTransfertId);
    if (current == null) {
      throw Exception('Recurring plan not found.');
    }

    final normalizedStartDate = _scheduleService.normalizeDate(
      request.startDate,
    );
    await Repository().upsert<RecurringTransfertModel>(
      RecurringTransfertModel(
        recurringTransfertId: current.recurringTransfertId,
        uid: _currentUid ?? current.uid,
        recurringTransfertTypeId: current.recurringTransfertTypeId,
        title: request.title,
        note: request.note,
        amount: request.amount,
        currency: request.currency,
        senderId: current.senderId,
        beneficiaryId: current.beneficiaryId,
        frequency: request.frequency,
        startDate: normalizedStartDate,
        nextDueDate: normalizedStartDate,
        endDate: current.endDate,
        status: current.status,
        executionMode: current.executionMode,
        reminderEnabled: current.reminderEnabled,
        lastGeneratedAt: current.lastGeneratedAt,
        lastConfirmedAt: current.lastConfirmedAt,
        createdAt: current.createdAt,
      ),
    );
  }

  @override
  Future<void> terminateRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    final now = DateTime.now().toIso8601String();
    await Repository().upsert<RecurringTransfertModel>(
      RecurringTransfertModel(
        recurringTransfertId: recurringTransfert.recurringTransfertId,
        uid: _currentUid ?? recurringTransfert.uid,
        recurringTransfertTypeId: recurringTransfert.recurringTransfertTypeId,
        title: recurringTransfert.title,
        note: recurringTransfert.note,
        amount: recurringTransfert.amount,
        currency: recurringTransfert.currency,
        senderId: recurringTransfert.senderId,
        beneficiaryId: recurringTransfert.beneficiaryId,
        frequency: recurringTransfert.frequency,
        startDate: recurringTransfert.startDate,
        nextDueDate: recurringTransfert.nextDueDate,
        endDate: now,
        status: AppRecurringTransfertState.inactive,
        executionMode: recurringTransfert.executionMode,
        reminderEnabled: false,
        lastGeneratedAt: recurringTransfert.lastGeneratedAt,
        lastConfirmedAt: recurringTransfert.lastConfirmedAt,
        createdAt: recurringTransfert.createdAt,
      ),
    );
  }

  @override
  Future<void> deleteRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    final linkedTransactions = await Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [
          Where.exact(
            'recurringTransfertId',
            recurringTransfert.recurringTransfertId,
          ),
        ],
      ),
    );

    for (final transaction in linkedTransactions) {
      await Repository().delete<TransactionModel>(transaction);
    }

    final current = await _findRecurringTransfert(
      recurringTransfert.recurringTransfertId ?? '',
    );
    if (current != null) {
      await Repository().delete<RecurringTransfertModel>(current);
    }
  }

  @override
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence, {
    required double confirmedAmount,
    required String confirmedCurrency,
    bool switchToAutomatic = false,
  }) async {
    final currentPlan = await _findRecurringTransfert(
      occurrence.recurringTransfert.recurringTransfertId ?? '',
    );
    if (currentPlan == null) {
      throw Exception('Recurring plan not found.');
    }

    final existingTransaction = await _findOccurrenceTransaction(
      currentPlan.recurringTransfertId ?? '',
      occurrence.expectedDate,
    );
    if (existingTransaction == null) {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: confirmedAmount,
        originalCurrencyCode: confirmedCurrency,
      );
      final transaction = TransactionModel(
        uid: _currentUid ?? currentPlan.uid,
        gtid: const Uuid().v4(),
        name: currentPlan.title,
        type: currentPlan.recurringTransfertTypeId,
        beneficiaryId: currentPlan.beneficiaryId,
        senderId: currentPlan.senderId,
        date: _scheduleService
            .mergeDateWithCurrentTime(occurrence.expectedDate)
            .toIso8601String(),
        note: currentPlan.note,
        amount: confirmedAmount,
        currency: confirmedCurrency,
        referenceCurrencyCode: quote.referenceCurrencyCode,
        convertedAmount: quote.convertedAmount,
        amountCdf: quote.amountCdf,
        rateToCdf: quote.rateToCdf,
        fxRateDate: quote.fxRateDate,
        fxSnapshotId: quote.fxSnapshotId,
        frequency: Frequency.oneTime,
        category: Constants.personal,
        createdAt: DateTime.now().toIso8601String(),
        recurringTransfertId: currentPlan.recurringTransfertId,
        recurringOccurrenceDate: occurrence.expectedDate.toIso8601String(),
        generationMode: TransactionTypes.generationManualConfirmation,
      );
      await Repository().upsert<TransactionModel>(transaction);
      if (_currentUid != null) {
        await _offlineFinanceLocalService.applyTransactionEffects(
          currentUserId: _currentUid!,
          transaction: transaction,
        );
      }
    }

    await Repository().upsert<RecurringTransfertModel>(
      RecurringTransfertModel(
        recurringTransfertId: currentPlan.recurringTransfertId,
        uid: _currentUid ?? currentPlan.uid,
        recurringTransfertTypeId: currentPlan.recurringTransfertTypeId,
        title: currentPlan.title,
        note: currentPlan.note,
        amount: currentPlan.amount,
        currency: currentPlan.currency,
        senderId: currentPlan.senderId,
        beneficiaryId: currentPlan.beneficiaryId,
        frequency: currentPlan.frequency,
        startDate: currentPlan.startDate,
        nextDueDate: currentPlan.nextDueDate,
        endDate: currentPlan.endDate,
        status: currentPlan.status,
        executionMode: switchToAutomatic
            ? AppExecutionMode.backendAutomatic
            : currentPlan.executionMode,
        reminderEnabled: switchToAutomatic
            ? false
            : currentPlan.reminderEnabled,
        lastGeneratedAt: currentPlan.lastGeneratedAt,
        lastConfirmedAt: DateTime.now().toIso8601String(),
        createdAt: currentPlan.createdAt,
      ),
    );
  }

  Future<RecurringTransfertModel?> _findRecurringTransfert(
    String recurringTransfertId,
  ) async {
    if (recurringTransfertId.isEmpty) {
      return null;
    }

    final items = await Repository().get<RecurringTransfertModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [Where.exact('recurringTransfertId', recurringTransfertId)],
      ),
    );
    return items.isEmpty ? null : items.first;
  }

  Future<TransactionModel?> _findOccurrenceTransaction(
    String recurringTransfertId,
    DateTime expectedDate,
  ) async {
    final items = await Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [Where.exact('recurringTransfertId', recurringTransfertId)],
      ),
    );
    final targetDay = _scheduleService.startOfDay(expectedDate);

    for (final item in items) {
      final occurrenceDate =
          _scheduleService.parseDate(item.recurringOccurrenceDate) ??
          _scheduleService.parseDate(item.date);
      if (occurrenceDate == null) {
        continue;
      }
      if (_scheduleService.isSameCalendarDay(targetDay, occurrenceDate)) {
        return item;
      }
    }

    return null;
  }
}
