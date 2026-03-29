part of 'graph_bloc.dart';

sealed class GraphEvent {
  const GraphEvent();
}

final class GraphStarted extends GraphEvent {
  const GraphStarted();
}

final class GraphPeriodChanged extends GraphEvent {
  const GraphPeriodChanged(this.period);

  final GraphPeriod period;
}

final class _GraphDashboardUpdated extends GraphEvent {
  const _GraphDashboardUpdated(this.dashboard);

  final GraphDashboardEntity dashboard;
}

final class _GraphDashboardFailed extends GraphEvent {
  const _GraphDashboardFailed(this.message);

  final String message;
}
