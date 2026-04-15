import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';

abstract class AnalysisRepository {
  Stream<AnalysisDashboardEntity> watchDashboard(AnalysisPeriod period);
}
