part of 'analysis_bloc.dart';

sealed class AnalysisEvent {
  const AnalysisEvent();
}

final class AnalysisStarted extends AnalysisEvent {
  const AnalysisStarted();
}

final class AnalysisPeriodChanged extends AnalysisEvent {
  const AnalysisPeriodChanged(this.period);

  final AnalysisPeriod period;
}

final class _AnalysisSourcesUpdated extends AnalysisEvent {
  const _AnalysisSourcesUpdated(this.mainState, this.currencyConfig);

  final MainState mainState;
  final CurrencyConfigEntity currencyConfig;
}

final class _AnalysisDashboardUpdated extends AnalysisEvent {
  const _AnalysisDashboardUpdated(this.dashboard);

  final AnalysisDashboardEntity dashboard;
}

final class _AnalysisDashboardFailed extends AnalysisEvent {
  const _AnalysisDashboardFailed(this.message);

  final String message;
}
