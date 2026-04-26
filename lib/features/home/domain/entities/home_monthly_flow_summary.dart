import 'package:equatable/equatable.dart';

class HomeMonthlyFlowSummary extends Equatable {
  const HomeMonthlyFlowSummary({
    required this.currentMonthInflow,
    required this.currentMonthOutflow,
    required this.previousMonthCarryover,
  });

  final double currentMonthInflow;
  final double currentMonthOutflow;
  final double previousMonthCarryover;

  double get inflowWithCarryover => currentMonthInflow + previousMonthCarryover;

  @override
  List<Object?> get props => [
    currentMonthInflow,
    currentMonthOutflow,
    previousMonthCarryover,
  ];
}
