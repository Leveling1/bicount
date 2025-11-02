import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'users'),
)
class FriendsModel extends OfflineFirstWithSupabaseModel {
  final String uid;
  final String image;
  final String username;
  final String email;

  @Supabase(unique: true, name: 'sid')
  @Sqlite(index: true, unique: true)
  final String sid;

  FriendsModel({
    String? sid,
    required this.uid,
    required this.image,
    required this.username,
    required this.email,
  })  : sid = sid ?? const Uuid().v4(),
        super();
}