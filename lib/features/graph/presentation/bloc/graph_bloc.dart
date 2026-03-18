import 'dart:async';

import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/repositories/graph_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'graph_event.dart';
part 'graph_state.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  GraphBloc(this.repository) : super(GraphState.initial()) {
    on<GraphStarted>(_onGraphStarted);
    on<GraphPeriodChanged>(_onGraphPeriodChanged);
    on<_GraphDashboardUpdated>(_onGraphDashboardUpdated);
    on<_GraphDashboardFailed>(_onGraphDashboardFailed);
  }

  final GraphRepository repository;
  StreamSubscription<GraphDashboardEntity>? _dashboardSubscription;

  Future<void> _onGraphStarted(
    GraphStarted event,
    Emitter<GraphState> emit,
  ) async {
    emit(state.copyWith(status: GraphStatus.loading));
    await _subscribeToDashboard(state.period);
  }

  Future<void> _onGraphPeriodChanged(
    GraphPeriodChanged event,
    Emitter<GraphState> emit,
  ) async {
    emit(state.copyWith(status: GraphStatus.loading, period: event.period));
    await _subscribeToDashboard(event.period);
  }

  void _onGraphDashboardUpdated(
    _GraphDashboardUpdated event,
    Emitter<GraphState> emit,
  ) {
    emit(
      state.copyWith(
        status: GraphStatus.success,
        dashboard: event.dashboard,
        errorMessage: null,
      ),
    );
  }

  void _onGraphDashboardFailed(
    _GraphDashboardFailed event,
    Emitter<GraphState> emit,
  ) {
    emit(
      state.copyWith(status: GraphStatus.failure, errorMessage: event.message),
    );
  }

  Future<void> _subscribeToDashboard(GraphPeriod period) async {
    await _dashboardSubscription?.cancel();
    _dashboardSubscription = repository
        .watchDashboard(period)
        .listen(
          (dashboard) => add(_GraphDashboardUpdated(dashboard)),
          onError: (error, _) => add(_GraphDashboardFailed(error.toString())),
        );
  }

  @override
  Future<void> close() async {
    await _dashboardSubscription?.cancel();
    return super.close();
  }
}
