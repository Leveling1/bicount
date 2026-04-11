import 'dart:async';

import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/services/graph_dashboard_builder.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'graph_event.dart';
part 'graph_state.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  GraphBloc({
    required this.mainBloc,
    required this.currencyRepository,
    this.dashboardBuilder = const GraphDashboardBuilder(),
  }) : super(GraphState.initial()) {
    on<GraphStarted>(_onGraphStarted);
    on<GraphPeriodChanged>(_onGraphPeriodChanged);
    on<_GraphSourcesUpdated>(_onGraphSourcesUpdated);
    on<_GraphDashboardUpdated>(_onGraphDashboardUpdated);
    on<_GraphDashboardFailed>(_onGraphDashboardFailed);
  }

  final MainBloc mainBloc;
  final CurrencyRepositoryImpl currencyRepository;
  final GraphDashboardBuilder dashboardBuilder;

  StreamSubscription<_GraphSourcesSnapshot>? _sourcesSubscription;
  MainState? _latestMainState;
  CurrencyConfigEntity _latestCurrencyConfig = CurrencyConfigEntity.fallback();

  Future<void> _onGraphStarted(
    GraphStarted event,
    Emitter<GraphState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GraphStatus.loading,
        clearDashboard: true,
        errorMessage: null,
      ),
    );

    await _sourcesSubscription?.cancel();
    _sourcesSubscription =
        Rx.combineLatest2<
              MainState,
              CurrencyConfigEntity,
              _GraphSourcesSnapshot
            >(
              mainBloc.stream.startWith(mainBloc.state),
              currencyRepository.watchConfig(),
              (mainState, currencyConfig) => _GraphSourcesSnapshot(
                mainState: mainState,
                currencyConfig: currencyConfig,
              ),
            )
            .listen(
              (snapshot) => add(
                _GraphSourcesUpdated(
                  snapshot.mainState,
                  snapshot.currencyConfig,
                ),
              ),
              onError: (error, _) =>
                  add(_GraphDashboardFailed(error.toString())),
            );
  }

  Future<void> _onGraphPeriodChanged(
    GraphPeriodChanged event,
    Emitter<GraphState> emit,
  ) async {
    if (event.period == state.period) {
      return;
    }

    emit(
      state.copyWith(
        status: state.dashboard == null ? GraphStatus.loading : state.status,
        period: event.period,
        errorMessage: null,
      ),
    );
    _rebuildDashboardForCurrentSources();
  }

  void _onGraphSourcesUpdated(
    _GraphSourcesUpdated event,
    Emitter<GraphState> emit,
  ) {
    _latestMainState = event.mainState;
    _latestCurrencyConfig = event.currencyConfig;

    final mainState = event.mainState;
    if (mainState is MainLoaded) {
      add(_GraphDashboardUpdated(_buildDashboard(mainState.startData)));
      return;
    }

    if (mainState is MainError) {
      emit(
        state.copyWith(
          status: GraphStatus.failure,
          clearDashboard: true,
          errorMessage: mainState.error,
        ),
      );
      return;
    }

    if (mainState is MainLoading || mainState is MainInitial) {
      emit(
        state.copyWith(
          status: GraphStatus.loading,
          clearDashboard: true,
          errorMessage: null,
        ),
      );
    }
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
      state.copyWith(
        status: GraphStatus.failure,
        clearDashboard: true,
        errorMessage: event.message,
      ),
    );
  }

  GraphDashboardEntity _buildDashboard(MainEntity mainData) {
    return dashboardBuilder.build(
      GraphSourceData(
        transactions: mainData.transactions,
        recurringTransferts: mainData.recurringTransferts,
        currentUserId: mainData.user.uid,
        friends: mainData.friends,
      ),
      state.period,
      _latestCurrencyConfig,
    );
  }

  void _rebuildDashboardForCurrentSources() {
    final mainState = _latestMainState;
    if (mainState is! MainLoaded) {
      return;
    }

    add(_GraphDashboardUpdated(_buildDashboard(mainState.startData)));
  }

  @override
  Future<void> close() async {
    await _sourcesSubscription?.cancel();
    return super.close();
  }
}

class _GraphSourcesSnapshot {
  const _GraphSourcesSnapshot({
    required this.mainState,
    required this.currencyConfig,
  });

  final MainState mainState;
  final CurrencyConfigEntity currencyConfig;
}
