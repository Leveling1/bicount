import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'memoji'),
)
class MemojiModel extends OfflineFirstWithSupabaseModel {
  final String name;
  final String link;
  final String sexe;
  final String test;

  @Supabase(unique: true, name: 'mid')
  @Sqlite(index: true, unique: true, name: 'mid')
  final String? mid;

  MemojiModel({
    String? mid,
    required this.name,
    required this.link,
    required this.sexe,
    required this.test,
  })  : mid = mid ?? const Uuid().v4(),
        super();
}