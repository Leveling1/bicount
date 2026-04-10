import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:flutter/foundation.dart';

class CurrencyRecordHistoryService {
  Future<Set<String>> collectStoredRateDates() async {
    final transactions = await _safeLocalGet<TransactionModel>();
    final subscriptions = await _safeLocalGet<SubscriptionModel>();
    final fundings = await _safeLocalGet<AccountFundingModel>();

    return {
      ...transactions.map((item) => item.fxRateDate).whereType<String>(),
      ...subscriptions.map((item) => item.fxRateDate).whereType<String>(),
      ...fundings.map((item) => item.fxRateDate).whereType<String>(),
    }.where((value) => value.isNotEmpty).toSet();
  }

  Future<List<T>>
  _safeLocalGet<T extends OfflineFirstWithSupabaseModel>() async {
    try {
      return await Repository().get<T>(policy: OfflineFirstGetPolicy.localOnly);
    } catch (error) {
      debugPrint('Currency history local read warning for $T: $error');
      return const [];
    }
  }
}
