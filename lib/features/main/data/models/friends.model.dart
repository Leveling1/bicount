import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'friends'),
)
class FriendsModel extends OfflineFirstWithSupabaseModel {
  final String? uid;
  final String? fid;
  final String image;
  final String username;
  final String email;
  final double? give;
  final double? receive;

  @Supabase(name: 'relation_type')
  @Sqlite()
  final int relationType;

  @Supabase(name: 'personal_income')
  @Sqlite()
  final double? personalIncome;

  @Supabase(name: 'company_income')
  @Sqlite()
  final double? companyIncome;

  @Supabase(unique: true, name: 'sid')
  @Sqlite(index: true, unique: true)
  final String sid;

  FriendsModel({
    String? sid,
    this.uid,
    this.fid,
    required this.image,
    required this.username,
    required this.email,
    this.give, 
    this.receive,
    required this.relationType,
    this.personalIncome,
    this.companyIncome,
  })  : sid = sid ?? const Uuid().v4(),
        super();
}