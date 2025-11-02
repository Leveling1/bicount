import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'transactions'),
)
class TransactionModel extends OfflineFirstWithSupabaseModel {
  @Sqlite(name: 'gtid')
  @Supabase(name: 'gtid')
  final String gtid;

  @Sqlite(name: 'name')
  @Supabase(name: 'name')
  final String name;

  @Sqlite(name: 'type')
  @Supabase(name: 'type')
  final String type;

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

  @Sqlite(name: 'image')
  @Supabase(name: 'image')
  final String? image;

  @Sqlite(name: 'frequency')
  @Supabase(name: 'frequency')
  final String? frequency;

  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createdAt;

  @Supabase(unique: true, name: 'tid')
  @Sqlite(index: true, unique: true, name: 'tid')
  final String? tid;

  TransactionModel({
  String? tid,
  required this.gtid,
  required this.name,
  required this.type,
  required this.beneficiaryId,
  required this.senderId,
  required this.date,
  required this.note,
  required this.amount,
  required this.currency,
  this.image,
  this.frequency,
  this.createdAt,
  })  : tid = tid ?? const Uuid().v4(),
        super();
}