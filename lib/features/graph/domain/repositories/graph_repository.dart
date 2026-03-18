import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';

abstract class GraphRepository {
  Stream<GraphDashboardEntity> watchDashboard(GraphPeriod period);
}
