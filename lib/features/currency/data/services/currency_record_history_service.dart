import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/foundation.dart';

class CurrencyRecordHistoryService {
  CurrencyRecordHistoryService({
    RecurringFundingScheduleService? scheduleService,
  }) : _scheduleService =
           scheduleService ?? const RecurringFundingScheduleService();

  final RecurringFundingScheduleService _scheduleService;

  Future<Set<String>> collectStoredRateDates() async {
    final transactions = await _safeLocalGet<TransactionModel>();
    final subscriptions = await _safeLocalGet<SubscriptionModel>();
    final fundings = await _safeLocalGet<AccountFundingModel>();
    final recurringTransferts = await _safeLocalGet<RecurringTransfertModel>();

    return {
      ...transactions.map((item) => item.fxRateDate).whereType<String>(),
      ...subscriptions.map((item) => item.fxRateDate).whereType<String>(),
      ...fundings.map((item) => item.fxRateDate).whereType<String>(),
      ...recurringTransferts
          .map(
            (item) => item.createdAt?.isNotEmpty == true
                ? item.createdAt!
                : _scheduleService.normalizeDate(item.startDate),
          )
          .where((value) => value.isNotEmpty),
    }.where((value) => value.isNotEmpty).toSet();
  }

  Future<Set<String>> collectRecurringTransfertCurrencies() async {
    final recurringTransferts = await _safeLocalGet<RecurringTransfertModel>();

    return recurringTransferts
        .map((item) => item.currency.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Future<List<T>> _safeLocalGet<T extends OfflineModel>() async {
    try {
      return await Repository().get<T>(policy: OfflineReadPolicy.localOnly);
    } catch (error) {
      debugPrint('Currency history local read warning for $T: $error');
      return const [];
    }
  }
}
