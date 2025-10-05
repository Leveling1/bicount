import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'start_data'),
)
class Start extends OfflineFirstWithSupabaseModel {
  final int idUserLink;
  final String name;
  final String? email;

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  Start({
    String? id,
    required this.idUserLink,
    required this.name,
    this.email
  }) : this.id = id ?? const Uuid().v4();
}
