import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/profile/data/models/recurring_funding.model.dart';
import 'package:brick_core/query.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_finance_local_service.dart';
import 'recurring_funding_schedule_service.dart';

class RecurringFundingLocalService {
  RecurringFundingLocalService({
    OfflineFinanceLocalService? offlineFinanceLocalService,
    RecurringFundingScheduleService scheduleService =
        const RecurringFundingScheduleService(),
  }) : _offlineFinanceLocalService =
           offlineFinanceLocalService ?? OfflineFinanceLocalService(),
       _scheduleService = scheduleService;

  final OfflineFinanceLocalService _offlineFinanceLocalService;
  final RecurringFundingScheduleService _scheduleService;
  final _client = Supabase.instance.client;

  String? get _currentUid => _client.auth.currentUser?.id;

  Future<void> createRecurringFunding(RecurringFundingModel funding) async {
    await Repository().upsert<RecurringFundingModel>(funding);
    await syncDueRecurringFundings(currentUserId: funding.uid);
  }

  Future<void> syncDueRecurringFundings({String? currentUserId}) async {
    final uid = currentUserId ?? _currentUid;
    if (uid == null) {
      return;
    }

    final recurringFundings = await Repository().get<RecurringFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [
          Where.exact('uid', uid),
          Where.exact('status', RecurringFundingStatus.active),
        ],
      ),
    );

    final today = _scheduleService.startOfDay(DateTime.now());
    for (final recurringFunding in recurringFundings) {
      final parsedNextDate = _scheduleService.parseDate(
        recurringFunding.nextFundingDate,
      );
      if (parsedNextDate == null) {
        continue;
      }

      var currentDate = _scheduleService.startOfDay(parsedNextDate);
      DateTime? lastProcessedDate;

      while (!currentDate.isAfter(today)) {
        final occurrenceFunding = AccountFundingModel(
          fundingId: _occurrenceFundingId(
            recurringFunding.recurringFundingId,
            currentDate,
          ),
          sid: uid,
          amount: recurringFunding.amount,
          currency: recurringFunding.currency,
          category: Constants.personal,
          fundingType: recurringFunding.fundingType,
          source: recurringFunding.source,
          note: recurringFunding.note,
          date: currentDate.toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
        );

        final existingFunding = await Repository().get<AccountFundingModel>(
          policy: OfflineFirstGetPolicy.localOnly,
          query: Query(
            where: [Where.exact('funding_id', occurrenceFunding.fundingId)],
          ),
        );

        if (existingFunding.isEmpty) {
          await Repository().upsert<AccountFundingModel>(occurrenceFunding);
          await _offlineFinanceLocalService.applyFundingEffects(
            occurrenceFunding,
          );
        }

        lastProcessedDate = currentDate;
        currentDate = _scheduleService.nextOccurrence(
          currentDate,
          recurringFunding.frequency,
        );
      }

      if (lastProcessedDate == null &&
          recurringFunding.nextFundingDate == currentDate.toIso8601String()) {
        continue;
      }

      await Repository().upsert<RecurringFundingModel>(
        RecurringFundingModel(
          recurringFundingId: recurringFunding.recurringFundingId,
          uid: recurringFunding.uid,
          source: recurringFunding.source,
          note: recurringFunding.note,
          amount: recurringFunding.amount,
          currency: recurringFunding.currency,
          fundingType: recurringFunding.fundingType,
          frequency: recurringFunding.frequency,
          startDate: recurringFunding.startDate,
          nextFundingDate: currentDate.toIso8601String(),
          lastProcessedAt: lastProcessedDate?.toIso8601String() ??
              recurringFunding.lastProcessedAt,
          status: recurringFunding.status,
          createdAt: recurringFunding.createdAt,
        ),
      );
    }
  }

  String _occurrenceFundingId(String recurringFundingId, DateTime value) {
    return '$recurringFundingId-${DateFormat('yyyyMMdd').format(value)}';
  }
}
