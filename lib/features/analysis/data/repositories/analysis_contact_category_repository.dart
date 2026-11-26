import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/features/analysis/data/models/analysis_contact_category.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';

class AnalysisContactCategoryRepository {
  AnalysisContactCategoryRepository({Repository? repository})
    : _repository = repository ?? Repository();

  final Repository _repository;

  Stream<List<AnalysisContactCategory>> watch(String ownerUid) =>
      _repository.subscribeToRealtime<AnalysisContactCategory>(
        query: Query(where: [Where.exact('owner_uid', ownerUid)]),
      );

  Future<void> save({
    required String ownerUid,
    required AnalysisChart chart,
    required Set<String> original,
    required Set<String> selected,
    required bool bothCharts,
  }) => _repository.saveAnalysisCategories(
    ownerUid: ownerUid,
    added: [
      for (final sid in selected.difference(original))
        AnalysisContactCategory.forContact(ownerUid, sid, chart),
      if (bothCharts)
        for (final sid in selected)
          AnalysisContactCategory.forContact(ownerUid, sid, chart.other),
    ],
    removed: [
      for (final sid in original.difference(selected))
        AnalysisContactCategory.forContact(ownerUid, sid, chart),
    ],
  );
}
