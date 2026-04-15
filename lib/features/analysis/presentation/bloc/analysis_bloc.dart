import 'dart:async';

import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'analysis_event.dart';
part 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  AnalysisBloc({
    required this.mainBloc,
    required this.currencyRepository,
    this.dashboardBuilder = const AnalysisDashboardBuilder(),
  }) : super(AnalysisState.initial()) {
    on<AnalysisStarted>(_onAnalysisStarted);
    on<AnalysisPeriodChanged>(_onAnalysisPeriodChanged);
    on<_AnalysisSourcesUpdated>(_onAnalysisSourcesUpdated);
    on<_AnalysisDashboardUpdated>(_onAnalysisDashboardUpdated);
    on<_AnalysisDashboardFailed>(_onAnalysisDashboardFailed);
  }

  final MainBloc mainBloc;
  final CurrencyRepositoryImpl currencyRepository;
  final AnalysisDashboardBuilder dashboardBuilder;

  StreamSubscription<_AnalysisSourcesSnapshot>? _sourcesSubscription;
  MainState? _latestMainState;
  CurrencyConfigEntity _latestCurrencyConfig = CurrencyConfigEntity.fallback();

  Future<void> _onAnalysisStarted(
    AnalysisStarted event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AnalysisStatus.loading,
        clearDashboard: true,
        errorMessage: null,
      ),
    );

    await _sourcesSubscription?.cancel();
    _sourcesSubscription =
        Rx.combineLatest2<
              MainState,
              CurrencyConfigEntity,
              _AnalysisSourcesSnapshot
            >(
              mainBloc.stream.startWith(mainBloc.state),
              currencyRepository.watchConfig(),
              (mainState, currencyConfig) => _AnalysisSourcesSnapshot(
                mainState: mainState,
                currencyConfig: currencyConfig,
              ),
            )
            .listen(
              (snapshot) => add(
                _AnalysisSourcesUpdated(
                  snapshot.mainState,
                  snapshot.currencyConfig,
                ),
              ),
              onError: (error, _) =>
                  add(_AnalysisDashboardFailed(error.toString())),
            );
  }

  Future<void> _onAnalysisPeriodChanged(
    AnalysisPeriodChanged event,
    Emitter<AnalysisState> emit,
  ) async {
    if (event.period == state.period) {
      return;
    }

    emit(
      state.copyWith(
        status: state.dashboard == null ? AnalysisStatus.loading : state.status,
        period: event.period,
        errorMessage: null,
      ),
    );
    _rebuildDashboardForCurrentSources();
  }

  void _onAnalysisSourcesUpdated(
    _AnalysisSourcesUpdated event,
    Emitter<AnalysisState> emit,
  ) {
    _latestMainState = event.mainState;
    _latestCurrencyConfig = event.currencyConfig;

    final mainState = event.mainState;
    if (mainState is MainLoaded) {
      add(_AnalysisDashboardUpdated(_buildDashboard(mainState.startData)));
      return;
    }

    if (mainState is MainError) {
      emit(
        state.copyWith(
          status: AnalysisStatus.failure,
          clearDashboard: true,
          errorMessage: mainState.error,
        ),
      );
      return;
    }

    if (mainState is MainLoading || mainState is MainInitial) {
      emit(
        state.copyWith(
          status: AnalysisStatus.loading,
          clearDashboard: true,
          errorMessage: null,
        ),
      );
    }
  }

  void _onAnalysisDashboardUpdated(
    _AnalysisDashboardUpdated event,
    Emitter<AnalysisState> emit,
  ) {
    emit(
      state.copyWith(
        status: AnalysisStatus.success,
        dashboard: event.dashboard,
        errorMessage: null,
      ),
    );
  }

  void _onAnalysisDashboardFailed(
    _AnalysisDashboardFailed event,
    Emitter<AnalysisState> emit,
  ) {
    emit(
      state.copyWith(
        status: AnalysisStatus.failure,
        clearDashboard: true,
        errorMessage: event.message,
      ),
    );
  }

  AnalysisDashboardEntity _buildDashboard(MainEntity mainData) {
    return dashboardBuilder.build(
      AnalysisSourceData(
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

    add(_AnalysisDashboardUpdated(_buildDashboard(mainState.startData)));
  }

  @override
  Future<void> close() async {
    await _sourcesSubscription?.cancel();
    return super.close();
  }
}

class _AnalysisSourcesSnapshot {
  const _AnalysisSourcesSnapshot({
    required this.mainState,
    required this.currencyConfig,
  });

  final MainState mainState;
  final CurrencyConfigEntity currencyConfig;
}
