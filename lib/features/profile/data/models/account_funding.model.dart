import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'account_funding'),
)
class AccountFundingModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'funding_id')
  @Sqlite(index: true, unique: true)
  final String fundingId;

  @Supabase(name: 'sid')
  @Sqlite()
  final String sid;

  @Supabase(name: 'amount')
  @Sqlite()
  final double amount;

  @Supabase(name: 'currency')
  @Sqlite()
  final String currency;

  @Supabase(name: 'category')
  @Sqlite()
  final int category;
  
  @Supabase(name: 'source')
  @Sqlite()
  final String source;

  @Supabase(name: 'note')
  @Sqlite()
  final String? note;

  @Supabase(name: 'date')
  @Sqlite()
  final String date;

  @Supabase(name: 'created_at')
  @Sqlite()
  final String? createdAt;

  AccountFundingModel({
    String? fundingId,
    required this.sid,
    required this.amount,
    required this.currency,
    required this.category,
    required this.source,
    required this.date,
    this.note,
    this.createdAt,
  })  : fundingId = fundingId ?? const Uuid().v4(),
        super();
}
