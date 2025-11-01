import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'user_links'),
)
class UserLinksModel extends OfflineFirstWithSupabaseModel {
  @Sqlite(name: 'user_a_id')
  @Supabase(name: 'user_a_id')
  final String userAID;

  @Sqlite(name: 'user_b_id')
  @Supabase(name: 'user_b_id')
  final String userBID;

  @Sqlite(name: 'link_type')
  @Supabase(name: 'link_type')
  final String linkType;

  @Sqlite(name: 'status')
  @Supabase(name: 'status')
  final String status;

  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createAt;

  @Supabase(unique: true, name: 'lid')
  @Sqlite(index: true, unique: true, name: 'lid')
  final String? lid;

  UserLinksModel({
    String? lid,
    required this.userAID,
    required this.userBID,
    required this.linkType,
    required this.status,
    this.createAt,
  })  : lid = lid ?? const Uuid().v4(),
        super();
}