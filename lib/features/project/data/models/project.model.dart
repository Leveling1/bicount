import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'projects'),
)
class ProjectModel extends OfflineFirstWithSupabaseModel {
  final String cid;
  final String name;
  final String initiator;
  final String? description;
  final String? image;
  final int? state;
  final double? profit;
  final String? createdAt;
  final String startDate;
  final String? endDate;

  @Supabase(unique: true, name: 'pid')
  @Sqlite(index: true, unique: true)
  final String? pid;

  ProjectModel({
    String? pid,
    required this.cid,
    required this.name,
    required this.initiator,
    required this.startDate,
    this.description,
    this.image,
    this.state,
    this.profit,
    this.endDate,
    this.createdAt,
  })  : pid = pid ?? const Uuid().v4(),
        super();
}