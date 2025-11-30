import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'users'),
)
class UserModel extends OfflineFirstWithSupabaseModel {
  @Supabase(name: 'uid')
  @Sqlite()
  final String uid;

  @Supabase(name: 'image')
  @Sqlite()
  final String image;

  @Supabase(name: 'username')
  @Sqlite()
  final String username;

  @Supabase(name: 'email')
  @Sqlite()
  final String email;

  @Supabase(name: 'incomes')
  @Sqlite()
  final double? incomes;

  @Supabase(name: 'expenses')
  @Sqlite()
  final double? expenses;

  @Supabase(name: 'profit')
  @Sqlite()
  final double? profit;

  @Supabase(name: 'company_income')
  @Sqlite()
  final double? companyIncome;

  @Supabase(name: 'personal_income')
  @Sqlite()
  final double? personalIncome;

  @Supabase(unique: true, name: 'sid')
  @Sqlite(index: true, unique: true)
  final String sid;

  UserModel({
    String? sid,
    required this.uid,
    required this.image,
    required this.username,
    required this.email,
    this.incomes,
    this.expenses,
    this.profit,
    this.companyIncome,
    this.personalIncome,
  }) : sid = sid ?? const Uuid().v4(),
       super();
}
