import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: TablesName.transactions),
)
class TransactionModel extends OfflineFirstWithSupabaseModel {
  @Sqlite(name: 'gtid')
  @Supabase(name: 'gtid')
  final String gtid;

  @Sqlite(name: 'uid')
  @Supabase(name: 'uid')
  final String uid;

  @Sqlite(name: 'name')
  @Supabase(name: 'name')
  final String name;

  @Sqlite(name: 'type')
  @Supabase(name: 'type')
  final int type;

  @Sqlite(name: 'beneficiary_id')
  @Supabase(name: 'beneficiary_id')
  final String beneficiaryId;

  @Sqlite(name: 'sender_id')
  @Supabase(name: 'sender_id')
  final String senderId;

  @Sqlite(name: 'date')
  @Supabase(name: 'date')
  final String date;

  @Sqlite(name: 'note')
  @Supabase(name: 'note')
  final String note;

  @Sqlite(name: 'amount')
  @Supabase(name: 'amount')
  final double amount;

  @Sqlite(name: 'currency')
  @Supabase(name: 'currency')
  final String currency;

  @Sqlite(name: 'reference_currency_code')
  @Supabase(name: 'reference_currency_code')
  final String? referenceCurrencyCode;

  @Sqlite(name: 'converted_amount')
  @Supabase(name: 'converted_amount')
  final double? convertedAmount;

  @Sqlite(name: 'amount_cdf')
  @Supabase(name: 'amount_cdf')
  final double? amountCdf;

  @Sqlite(name: 'rate_to_cdf')
  @Supabase(name: 'rate_to_cdf')
  final double? rateToCdf;

  @Sqlite(name: 'fx_rate_date')
  @Supabase(name: 'fx_rate_date')
  final String? fxRateDate;

  @Sqlite(name: 'fx_snapshot_id')
  @Supabase(name: 'fx_snapshot_id')
  final String? fxSnapshotId;

  @Sqlite(name: 'image')
  @Supabase(name: 'image')
  final String? image;

  @Sqlite(name: 'frequency')
  @Supabase(name: 'frequency')
  final int? frequency;

  @Sqlite(name: 'category')
  @Supabase(name: 'category')
  final int? category;

  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createdAt;

  @Sqlite(name: 'recurring_transfert_id')
  @Supabase(name: 'recurring_transfert_id')
  final String? recurringTransfertId;

  @Sqlite(name: 'recurring_occurrence_date')
  @Supabase(name: 'recurring_occurrence_date')
  final String? recurringOccurrenceDate;

  @Sqlite(name: 'generation_mode')
  @Supabase(name: 'generation_mode')
  final int? generationMode;

  @Supabase(unique: true, name: 'tid')
  @Sqlite(index: true, unique: true, name: 'tid')
  final String? tid;

  TransactionModel({
    String? tid,
    required this.uid,
    required this.gtid,
    required this.name,
    required this.type,
    required this.beneficiaryId,
    required this.senderId,
    required this.date,
    required this.note,
    required this.amount,
    required this.currency,
    this.referenceCurrencyCode,
    this.convertedAmount,
    this.amountCdf,
    this.rateToCdf,
    this.fxRateDate,
    this.fxSnapshotId,
    this.category,
    this.image,
    this.frequency,
    this.createdAt,
    this.recurringTransfertId,
    this.recurringOccurrenceDate,
    this.generationMode,
  }) : tid = tid ?? const Uuid().v4(),
       super();
}
