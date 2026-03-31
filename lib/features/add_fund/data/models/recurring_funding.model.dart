import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: TablesName.recurringFundings),
)
class RecurringFundingModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'recurring_funding_id')
  @Sqlite(index: true, unique: true)
  final String recurringFundingId;

  @Supabase(name: 'uid')
  @Sqlite(index: true)
  final String uid;

  @Supabase(name: 'source')
  @Sqlite()
  final String source;

  @Supabase(name: 'note')
  @Sqlite()
  final String? note;

  @Supabase(name: 'amount')
  @Sqlite()
  final double amount;

  @Supabase(name: 'currency')
  @Sqlite()
  final String currency;

  @Supabase(name: 'funding_type')
  @Sqlite()
  final int fundingType;

  @Supabase(name: 'frequency')
  @Sqlite()
  final int frequency;

  @Supabase(name: 'start_date')
  @Sqlite()
  final String startDate;

  @Supabase(name: 'next_funding_date')
  @Sqlite()
  final String nextFundingDate;

  @Supabase(name: 'last_processed_at')
  @Sqlite()
  final String? lastProcessedAt;

  @Supabase(name: 'status')
  @Sqlite()
  final int status;

  @Supabase(name: 'salary_processing_mode')
  @Sqlite()
  final int salaryProcessingMode;

  @Supabase(name: 'salary_reminder_status')
  @Sqlite()
  final int salaryReminderStatus;

  @Supabase(name: 'created_at')
  @Sqlite()
  final String? createdAt;

  RecurringFundingModel({
    String? recurringFundingId,
    required this.uid,
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
    this.fundingType = AccountFundingType.other,
    required this.frequency,
    required this.startDate,
    required this.nextFundingDate,
    this.lastProcessedAt,
    this.status = RecurringFundingStatus.active,
    this.salaryProcessingMode = SalaryProcessingMode.automatic,
    this.salaryReminderStatus = SalaryReminderStatus.enabled,
    this.createdAt,
  }) : recurringFundingId = recurringFundingId ?? const Uuid().v4(),
       super();
}
