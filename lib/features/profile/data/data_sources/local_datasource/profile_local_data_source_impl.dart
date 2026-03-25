import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/core/services/recurring_funding_local_service.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:bicount/features/profile/data/data_sources/local_datasource/profile_local_datasource.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/profile/data/models/recurring_funding.model.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  final OfflineFinanceLocalService _offlineFinanceLocalService =
      OfflineFinanceLocalService();
  final RecurringFundingLocalService _recurringFundingLocalService =
      RecurringFundingLocalService();
  final RecurringFundingScheduleService _scheduleService =
      const RecurringFundingScheduleService();

  String? get _currentUid => supabaseInstance.auth.currentUser?.id;

  @override
  Future<void> addAccountFunding(AddAccountFundingEntity data) async {
    try {
      final sid = data.sid ?? _currentUid;
      if (sid == null) {
        throw Exception('Authentication failure');
      }

      final accountFundingData = AccountFundingModel(
        fundingId: Uuid().v4(),
        sid: sid,
        source: data.source,
        note: data.note,
        amount: data.amount,
        currency: data.currency,
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
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        return;
      }

      await Repository().upsert<AccountFundingModel>(accountFundingData);
      await _offlineFinanceLocalService.applyFundingEffects(accountFundingData);
    } catch (e) {
      rethrow;
    }
  }

  // Add your local data source implementation here
}
