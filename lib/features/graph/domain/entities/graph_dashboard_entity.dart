import 'package:equatable/equatable.dart';

enum GraphPeriod { week7, month30, quarter90, all }

extension GraphPeriodX on GraphPeriod {
  String get label {
    switch (this) {
      case GraphPeriod.week7:
        return '7D';
      case GraphPeriod.month30:
        return '30D';
      case GraphPeriod.quarter90:
        return '90D';
      case GraphPeriod.all:
        return 'All';
    }
  }

  String get description {
    switch (this) {
      case GraphPeriod.week7:
        return 'Last 7 days';
      case GraphPeriod.month30:
        return 'Last 30 days';
      case GraphPeriod.quarter90:
        return 'Last 90 days';
      case GraphPeriod.all:
        return 'All history';
    }
  }
}

class GraphDashboardEntity extends Equatable {
  const GraphDashboardEntity({
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

  final GraphPeriod period;
  final String displayCurrencyCode;
  final double inflow;
  final double outflow;
  final double netFlow;
  final List<GraphCashflowPoint> cashflowPoints;
  final List<GraphBreakdownItem> incomeBreakdown;
  final List<GraphBreakdownItem> expenseBreakdown;
  final GraphRecurringSummary recurringCharges;
  final GraphRecurringSummary recurringIncomes;

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

class GraphRecurringSummary extends Equatable {
  const GraphRecurringSummary({
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

class GraphCashflowPoint extends Equatable {
  const GraphCashflowPoint({
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

class GraphBreakdownItem extends Equatable {
  const GraphBreakdownItem({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}
