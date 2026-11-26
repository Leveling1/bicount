enum AnalysisChart {
  income,
  expense;

  AnalysisChart get other => this == income ? expense : income;
}
