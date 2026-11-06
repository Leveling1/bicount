import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/core/offline/legacy_recurring_adapter.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';

import 'offline_finance_local_service.dart';
import 'recurring_funding_schedule_service.dart';

class RecurringFundingLocalService {
  RecurringFundingLocalService({
    CurrencyRepositoryImpl? currencyRepository,
    OfflineFinanceLocalService? offlineFinanceLocalService,
    RecurringFundingScheduleService scheduleService =
        const RecurringFundingScheduleService(),
  });

  Future<void> createRecurringFunding(RecurringFundingModel funding) async {
    await Repository().upsert<RecurringTransfertModel>(
      fundingPlanAsRecurring(funding),
    );
  }

  Future<void> syncDueRecurringFundings({String? currentUserId}) async {
    // Concrete account funding rows are no longer generated locally from
    // recurring templates. The mobile app keeps recurring rules for tracking,
    // while real money is counted only from `transactions` rows created
    // by explicit user confirmation or backend-side automation.
  }
}
