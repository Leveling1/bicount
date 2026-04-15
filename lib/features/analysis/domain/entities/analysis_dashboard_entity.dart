import 'package:equatable/equatable.dart';

enum AnalysisPeriod { week7, month30, quarter90, all }

extension AnalysisPeriodX on AnalysisPeriod {
  String get label {
    switch (this) {
      case AnalysisPeriod.week7:
        return '7D';
      case AnalysisPeriod.month30:
        return '30D';
      case AnalysisPeriod.quarter90:
        return '90D';
      case AnalysisPeriod.all:
        return 'All';
    }
  }

  String get description {
    switch (this) {
      case AnalysisPeriod.week7:
        return 'Last 7 days';
      case AnalysisPeriod.month30:
        return 'Last 30 days';
      case AnalysisPeriod.quarter90:
        return 'Last 90 days';
      case AnalysisPeriod.all:
        return 'All history';
    }
  }
}

class AnalysisDashboardEntity extends Equatable {
  const AnalysisDashboardEntity({
    required this.period,
    required this.displayCurrencyCode,
    required this.inflow,
    required this.outflow,
    required this.netFlow,
    required this.cashflowPoints,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.recurringCharges,
    required this.recurringIncomes,
  });

  final AnalysisPeriod period;
  final String displayCurrencyCode;
  final double inflow;
  final double outflow;
  final double netFlow;
  final List<AnalysisCashflowPoint> cashflowPoints;
  final List<AnalysisBreakdownItem> incomeBreakdown;
  final List<AnalysisBreakdownItem> expenseBreakdown;
  final AnalysisRecurringSummary recurringCharges;
  final AnalysisRecurringSummary recurringIncomes;

  @override
  List<Object?> get props => [
    period,
    displayCurrencyCode,
    inflow,
    outflow,
    netFlow,
    cashflowPoints,
    incomeBreakdown,
    expenseBreakdown,
    recurringCharges,
    recurringIncomes,
  ];
}

class AnalysisRecurringSummary extends Equatable {
  const AnalysisRecurringSummary({
    required this.totalCount,
    required this.activeCount,
    required this.upcomingCount,
    required this.monthlyReferenceAmount,
    required this.nextExpectedDate,
  });

  final int totalCount;
  final int activeCount;
  final int upcomingCount;
  final double monthlyReferenceAmount;
  final DateTime? nextExpectedDate;

  bool get hasPlans => totalCount > 0;

  @override
  List<Object?> get props => [
    totalCount,
    activeCount,
    upcomingCount,
    monthlyReferenceAmount,
    nextExpectedDate,
  ];
}

class AnalysisCashflowPoint extends Equatable {
  const AnalysisCashflowPoint({
    required this.date,
    required this.inflow,
    required this.outflow,
    required this.cumulativeNet,
  });

  final DateTime date;
  final double inflow;
  final double outflow;
  final double cumulativeNet;

  @override
  List<Object?> get props => [date, inflow, outflow, cumulativeNet];
}

class AnalysisBreakdownItem extends Equatable {
  const AnalysisBreakdownItem({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}
