part of 'graph_bloc.dart';

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
    GraphDashboardEntity? dashboard,
    String? errorMessage,
  }) {
    return GraphState(
      status: status ?? this.status,
      period: period ?? this.period,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage,
    );
  }
}
