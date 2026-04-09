import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(
    tableName: TablesName.recurringTransfert,
  ),
)
class RecurringTransfertModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'recurring_transfert_id')
  @Sqlite(index: true, unique: true, name: 'recurring_transfert_id')
  final String? recurringTransfertId;

  @Supabase(name: 'uid')
  @Sqlite(index: true, name: 'uid')
  final String uid;

  @Supabase(name: 'recurring_transfert_type_id')
  @Sqlite(name: 'recurring_transfert_type_id')
  final int recurringTransfertTypeId;

  @Supabase(name: 'title')
  @Sqlite(name: 'title')
  final String title;

  @Supabase(name: 'note')
  @Sqlite(name: 'note')
  final String note;

  @Supabase(name: 'amount')
  @Sqlite(name: 'amount')
  final double amount;

  @Supabase(name: 'currency')
  @Sqlite(name: 'currency')
  final String currency;

  @Supabase(name: 'sender_id')
  @Sqlite(name: 'sender_id')
  final String senderId;

  @Supabase(name: 'beneficiary_id')
  @Sqlite(name: 'beneficiary_id')
  final String beneficiaryId;

  @Supabase(name: 'frequency')
  @Sqlite(name: 'frequency')
  final int frequency;

  @Supabase(name: 'start_date')
  @Sqlite(name: 'start_date')
  final String startDate;

  @Supabase(name: 'next_due_date')
  @Sqlite(name: 'next_due_date')
  final String nextDueDate;

  @Supabase(name: 'end_date')
  @Sqlite(name: 'end_date')
  final String? endDate;

  @Supabase(name: 'status')
  @Sqlite(name: 'status')
  final int status;

  @Supabase(name: 'execution_mode')
  @Sqlite(name: 'execution_mode')
  final int executionMode;

  @Supabase(name: 'reminder_enabled')
  @Sqlite(name: 'reminder_enabled')
  final bool reminderEnabled;

  @Supabase(name: 'last_generated_at')
  @Sqlite(name: 'last_generated_at')
  final String? lastGeneratedAt;

  @Supabase(name: 'last_confirmed_at')
  @Sqlite(name: 'last_confirmed_at')
  final String? lastConfirmedAt;

  @Supabase(name: 'created_at')
  @Sqlite(name: 'created_at')
  final String? createdAt;

  RecurringTransfertModel({
    String? recurringTransfertId,
    required this.uid,
    required this.recurringTransfertTypeId,
    required this.title,
    this.note = '',
    required this.amount,
    required this.currency,
    required this.senderId,
    required this.beneficiaryId,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.endDate,
    this.status = 0,
    this.executionMode = 0,
    this.reminderEnabled = true,
    this.lastGeneratedAt,
    this.lastConfirmedAt,
    this.createdAt,
  }) : recurringTransfertId = recurringTransfertId ?? const Uuid().v4(),
       super();
}
