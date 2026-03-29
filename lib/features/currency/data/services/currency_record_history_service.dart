import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';

class CurrencyRecordHistoryService {
  Future<Set<String>> collectStoredRateDates() async {
    final transactions = await Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    final subscriptions = await Repository().get<SubscriptionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    final fundings = await Repository().get<AccountFundingModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );

    return {
      ...transactions.map((item) => item.fxRateDate).whereType<String>(),
      ...subscriptions.map((item) => item.fxRateDate).whereType<String>(),
      ...fundings.map((item) => item.fxRateDate).whereType<String>(),
    }.where((value) => value.isNotEmpty).toSet();
  }
}
