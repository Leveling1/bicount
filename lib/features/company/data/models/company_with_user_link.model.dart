import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'company_with_user_link'),
)
class CompanyWithUserLinkModel extends OfflineFirstWithSupabaseModel {
  @Sqlite(name: 'company_id')
  @Supabase(name: 'company_id')
  final String companyId;

  @Sqlite(name: 'user_id')
  @Supabase(name: 'user_id')
  final String userId;

  @Sqlite()
  @Supabase()
  final String role;

  @Supabase(unique: true, name: 'lid')
  @Sqlite(index: true, unique: true, name: 'lid')
  final String? lid;

  CompanyWithUserLinkModel({
    String? lid,
    required this.companyId,
    required this.userId,
    required this.role,
  })  : lid = lid ?? const Uuid().v4(),
        super();
}