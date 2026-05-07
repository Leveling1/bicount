import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: TablesName.debts),
)
class DebtModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'debt_id')
  @Sqlite(index: true, unique: true, name: 'debt_id')
  final String? debtId;

  @Supabase(name: 'created_by')
  @Sqlite(index: true, name: 'created_by')
  final String createdBy;

  @Supabase(name: 'lender_id')
  @Sqlite(index: true, name: 'lender_id')
  final String lenderId;

  @Supabase(name: 'borrower_id')
  @Sqlite(index: true, name: 'borrower_id')
  final String borrowerId;

  @Supabase(name: 'principal_transaction_id')
  @Sqlite(index: true, unique: true, name: 'principal_transaction_id')
  final String principalTransactionId;

  @Supabase(name: 'title')
  @Sqlite(name: 'title')
  final String title;

  @Supabase(name: 'note')
  @Sqlite(name: 'note')
  final String note;

  @Supabase(name: 'currency')
  @Sqlite(name: 'currency')
  final String currency;

  @Supabase(name: 'principal_amount')
  @Sqlite(name: 'principal_amount')
  final double principalAmount;

  @Supabase(name: 'expected_repayment_amount')
  @Sqlite(name: 'expected_repayment_amount')
  final double expectedRepaymentAmount;

  @Supabase(name: 'repaid_amount')
  @Sqlite(name: 'repaid_amount')
  final double repaidAmount;

  @Supabase(name: 'remaining_amount')
  @Sqlite(name: 'remaining_amount')
  final double remainingAmount;

  @Supabase(name: 'due_date')
  @Sqlite(name: 'due_date')
  final String dueDate;

  @Supabase(name: 'status')
  @Sqlite(name: 'status')
  final int status;

  @Supabase(name: 'reminder_enabled')
  @Sqlite(name: 'reminder_enabled')
  final bool reminderEnabled;

  @Supabase(name: 'last_due_notification_at')
  @Sqlite(name: 'last_due_notification_at')
  final String? lastDueNotificationAt;

  @Supabase(name: 'closed_at')
  @Sqlite(name: 'closed_at')
  final String? closedAt;

  @Supabase(name: 'created_at')
  @Sqlite(name: 'created_at')
  final String? createdAt;

  @Supabase(name: 'updated_at')
  @Sqlite(name: 'updated_at')
  final String? updatedAt;

  DebtModel({
    String? debtId,
    required this.createdBy,
    required this.lenderId,
    required this.borrowerId,
    required this.principalTransactionId,
    required this.title,
    this.note = '',
    required this.currency,
    required this.principalAmount,
    required this.expectedRepaymentAmount,
    this.repaidAmount = 0,
    required this.remainingAmount,
    required this.dueDate,
    this.status = 0,
    this.reminderEnabled = true,
    this.lastDueNotificationAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  }) : debtId = debtId ?? const Uuid().v4(),
       super();
}
