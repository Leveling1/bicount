part of 'analysis_bloc.dart';

const _analysisUnset = Object();

enum AnalysisStatus { initial, loading, success, failure }

class AnalysisState {
  const AnalysisState({
    required this.status,
    required this.period,
    this.dashboard,
    this.errorMessage,
  });

  final AnalysisStatus status;
  final AnalysisPeriod period;
  final AnalysisDashboardEntity? dashboard;
  final String? errorMessage;

  factory AnalysisState.initial() {
    return const AnalysisState(
      status: AnalysisStatus.initial,
      period: AnalysisPeriod.month30,
    );
  }

  AnalysisState copyWith({
    AnalysisStatus? status,
    AnalysisPeriod? period,
    Object? dashboard = _analysisUnset,
    bool clearDashboard = false,
    String? errorMessage,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      period: period ?? this.period,
      dashboard: clearDashboard
          ? null
          : (dashboard == _analysisUnset
                ? this.dashboard
                : dashboard as AnalysisDashboardEntity?),
      errorMessage: errorMessage,
    );
  }
}
