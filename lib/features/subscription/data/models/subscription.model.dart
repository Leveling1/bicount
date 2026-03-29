import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: TablesName.subscriptions),
)
class SubscriptionModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'subscription_id')
  @Sqlite(index: true, unique: true, name: 'subscription_id')
  final String? subscriptionId;

  @Sqlite(name: 'sid')
  @Supabase(name: 'sid')
  final String sid;

  @Sqlite(name: 'title')
  @Supabase(name: 'title')
  final String title;

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

  @Sqlite(name: 'frequency')
  @Supabase(name: 'frequency')
  final int frequency;

  @Sqlite(name: 'start_date')
  @Supabase(name: 'start_date')
  final String startDate;

  @Sqlite(name: 'next_billing_date')
  @Supabase(name: 'next_billing_date')
  final String nextBillingDate;

  @Sqlite(name: 'end_date')
  @Supabase(name: 'end_date')
  final String? endDate;

  @Sqlite(name: 'notes')
  @Supabase(name: 'notes')
  final String? notes;

  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createdAt;

  @Sqlite(name: 'category')
  @Supabase(name: 'category')
  final int? category;

  @Sqlite(name: 'status')
  @Supabase(name: 'status')
  final int? status;

  SubscriptionModel({
    String? subscriptionId,
    required this.sid,
    required this.title,
    required this.amount,
    required this.currency,
    this.referenceCurrencyCode,
    this.convertedAmount,
    this.amountCdf,
    this.rateToCdf,
    this.fxRateDate,
    this.fxSnapshotId,
    required this.frequency,
    required this.startDate,
    required this.nextBillingDate,
    this.endDate,
    this.notes,
    this.createdAt,
    this.category,
    this.status,
  }) : subscriptionId = subscriptionId ?? const Uuid().v4(),
       super();
}
