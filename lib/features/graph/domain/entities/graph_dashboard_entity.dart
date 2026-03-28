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
    required this.inflow,
    required this.outflow,
    required this.netFlow,
    required this.activeSubscriptionCount,
    required this.monthlySubscriptionSpend,
    required this.dueSoonAmount,
    required this.cashflowPoints,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.upcomingSubscriptions,
  });

  final GraphPeriod period;
  final double inflow;
  final double outflow;
  final double netFlow;
  final int activeSubscriptionCount;
  final double monthlySubscriptionSpend;
  final double dueSoonAmount;
  final List<GraphCashflowPoint> cashflowPoints;
  final List<GraphBreakdownItem> incomeBreakdown;
  final List<GraphBreakdownItem> expenseBreakdown;
  final List<UpcomingSubscriptionEntity> upcomingSubscriptions;

  @override
  List<Object?> get props => [
    period,
    inflow,
    outflow,
    netFlow,
    activeSubscriptionCount,
    monthlySubscriptionSpend,
    dueSoonAmount,
    cashflowPoints,
    incomeBreakdown,
    expenseBreakdown,
    upcomingSubscriptions,
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

class UpcomingSubscriptionEntity extends Equatable {
  const UpcomingSubscriptionEntity({
    required this.subscriptionId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.nextBillingDate,
    required this.frequency,
  });

  final String subscriptionId;
  final String title;
  final double amount;
  final String currency;
  final DateTime nextBillingDate;
  final int frequency;

  @override
  List<Object?> get props => [
    subscriptionId,
    title,
    amount,
    currency,
    nextBillingDate,
    frequency,
  ];
}
