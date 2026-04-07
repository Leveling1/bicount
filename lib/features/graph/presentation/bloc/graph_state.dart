part of 'graph_bloc.dart';

const _graphUnset = Object();

enum GraphStatus { initial, loading, success, failure }

class GraphState {
  const GraphState({
    required this.status,
    required this.period,
    this.dashboard,
    this.errorMessage,
  });

  final GraphStatus status;
  final GraphPeriod period;
  final GraphDashboardEntity? dashboard;
  final String? errorMessage;

  factory GraphState.initial() {
    return const GraphState(
      status: GraphStatus.initial,
      period: GraphPeriod.month30,
    );
  }

  GraphState copyWith({
    GraphStatus? status,
    GraphPeriod? period,
    Object? dashboard = _graphUnset,
    bool clearDashboard = false,
    String? errorMessage,
  }) {
    return GraphState(
      status: status ?? this.status,
      period: period ?? this.period,
      dashboard: clearDashboard
          ? null
          : (dashboard == _graphUnset
                ? this.dashboard
                : dashboard as GraphDashboardEntity?),
      errorMessage: errorMessage,
    );
  }
}
