import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:uuid/uuid.dart';

class AnalysisContactCategory extends OfflineModel {
  const AnalysisContactCategory({
    required this.id,
    required this.ownerUid,
    required this.friendSid,
    required this.chart,
  });

  factory AnalysisContactCategory.forContact(
    String ownerUid,
    String friendSid,
    AnalysisChart chart,
  ) => AnalysisContactCategory(
    id: const Uuid().v5(
      Namespace.url.value,
      'bicount:analysis-contact:$ownerUid:$friendSid:${chart.name}',
    ),
    ownerUid: ownerUid,
    friendSid: friendSid,
    chart: chart,
  );

  factory AnalysisContactCategory.fromRow(Map<String, dynamic> row) =>
      AnalysisContactCategory(
        id: row['category_id'] as String,
        ownerUid: row['owner_uid'] as String,
        friendSid: row['friend_sid'] as String,
        chart: AnalysisChart.values.byName(row['chart'] as String),
      );

  final String id;
  final String ownerUid;
  final String friendSid;
  final AnalysisChart chart;

  Map<String, dynamic> toRow() => {
    'category_id': id,
    'owner_uid': ownerUid,
    'friend_sid': friendSid,
    'chart': chart.name,
  };
}
