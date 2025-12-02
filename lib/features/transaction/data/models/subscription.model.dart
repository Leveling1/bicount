import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'subscriptions'),
)
class SubscriptionModel extends OfflineFirstWithSupabaseModel {
  // Unique ID
  @Supabase(unique: true, name: 'subscription_id')
  @Sqlite(index: true, unique: true, name: 'subscription_id')
  final String? subscriptionId;

  // User ID
  @Sqlite(name: 'sid')
  @Supabase(name: 'sid')
  final String sid;

  // Subscription title
  @Sqlite(name: 'title')
  @Supabase(name: 'title')
  final String title;

  // Amount
  @Sqlite(name: 'amount')
  @Supabase(name: 'amount')
  final double amount;

  // Currency (USD, EUR, CDF...)
  @Sqlite(name: 'currency')
  @Supabase(name: 'currency')
  final String currency;

  // Billing frequency (monthly, yearly, weekly...)
  @Sqlite(name: 'frequency')
  @Supabase(name: 'frequency')
  final int frequency;

  // Start date of subscription
  @Sqlite(name: 'start_date')
  @Supabase(name: 'start_date')
  final String startDate;

  @Sqlite(name: 'next_billing_date')
  @Supabase(name: 'next_billing_date')
  final String nextBillingDate;

  // End date (optional)
  @Sqlite(name: 'end_date')
  @Supabase(name: 'end_date')
  final String? endDate;

  // Notes (optional)
  @Sqlite(name: 'notes')
  @Supabase(name: 'notes')
  final String? notes;

  // Auto created_at
  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createdAt;

  // Status of the subscription (active, paused, cancelled)
  @Sqlite(name: 'status')
  @Supabase(name: 'status')
  final int? status;

  SubscriptionModel({
    String? subscriptionId,
    required this.sid,
    required this.title,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
    required this.nextBillingDate,
    this.endDate,
    this.notes,
    this.createdAt,
    this.status,
  }) : subscriptionId = subscriptionId ?? const Uuid().v4(),
       super();
}
