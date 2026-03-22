import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tables_name.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: TablesName.users),
)
class UserModel extends OfflineFirstWithSupabaseModel {

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

  @Supabase(name: 'balance')
  @Sqlite()
  final double? balance;

  @Supabase(name: 'company_income')
  @Sqlite()
  final double? companyIncome;

  @Supabase(name: 'personal_income')
  @Sqlite()
  final double? personalIncome;

  @Supabase(unique: true, name: 'uid')
  @Sqlite(index: true, unique: true)
  final String uid;

  UserModel({
    String? uid,
    required this.image,
    required this.username,
    required this.email,
    this.balance,
    this.incomes,
    this.expenses,
    this.companyIncome,
    this.personalIncome,
  }) : uid = uid ?? const Uuid().v4(),
       super();
}
