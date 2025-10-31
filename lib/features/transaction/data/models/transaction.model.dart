import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'transactions'),
)
class TransactionModel extends OfflineFirstWithSupabaseModel {
  final String name;
  final String? description;
  final String? image;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? salary;
  final double? equipment;
  final double? service;
  final String createdAt;

  @Supabase(unique: true, name: 'tid')
  @Sqlite(index: true, unique: true)
  final String? tid;

  TransactionModel({
    String? tid,
    required this.name,
    this.description,
    this.image,
    this.sales,
    this.expenses,
    this.profit,
    this.salary,
    this.equipment,
    this.service,
    required this.createdAt,
  })  : tid = tid ?? const Uuid().v4(),
        super();
}