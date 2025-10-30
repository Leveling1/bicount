import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'groups'),
)
class GroupModel extends OfflineFirstWithSupabaseModel {
  final String cid;
  final String name;
  final String? description;
  final String? image;
  final int? number;
  final String createdAt;

  @Supabase(unique: true, name: 'gid')
  @Sqlite(index: true, unique: true)
  final String? gid;

  GroupModel({
    String? gid,
    required this.cid,
    required this.name,
    this.description,
    this.number,
    this.image,
    required this.createdAt,
  })  : gid = gid ?? const Uuid().v4(),
        super();
}