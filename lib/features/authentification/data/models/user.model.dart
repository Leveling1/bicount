import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'users'),
)
class UserModel extends OfflineFirstWithSupabaseModel {
  final String uid;
  final String username;
  final String email;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? companyIncome;
  final double? personalIncome;

  @Supabase(unique: true, name: 'sid')
  @Sqlite(index: true, unique: true)
  final String sid;

  UserModel({
    String? sid,
    required this.uid,
    required this.username,
    required this.email,
    required this.sales,
    required this.expenses,
    required this.profit,
    required this.companyIncome,
    required this.personalIncome,
  })  : sid = sid ?? const Uuid().v4(),
        super();
}