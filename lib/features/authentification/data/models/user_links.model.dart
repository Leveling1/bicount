import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'user_links'),
)
class UserLinkModel extends OfflineFirstWithSupabaseModel {
  @Sqlite()
  @Supabase(name: 'user_a_id')
  final String userAId;

  @Sqlite()
  @Supabase(name: 'user_b_id')
  final String userBId;

  @Sqlite()
  @Supabase(name: 'link_type')
  final String linkType;

  @Sqlite()
  @Supabase(name: 'status')
  final String status;

  @Supabase(unique: true, name: 'lid')
  @Sqlite(index: true, unique: true, name: 'lid')
  final String? lid;

  UserLinkModel({
    String? lid,
    required this.userAId,
    required this.userBId,
    required this.linkType,
    required this.status,
  })  : lid = lid ?? const Uuid().v4(),
        super();
}