import 'package:equatable/equatable.dart';

class HomeMonthlyFlowSummary extends Equatable {
  const HomeMonthlyFlowSummary({
    required this.currentMonthInflow,
    required this.currentMonthOutflow,
    required this.carryover,
  });

  final double currentMonthInflow;
  final double currentMonthOutflow;

  /// Net of every transaction recorded before the current month, signed.
  /// A negative value means the month opened in deficit — the app mirrors
  /// reality, so an overdraft is carried forward instead of being hidden.
  final double carryover;

  /// Because [carryover] spans the whole history and is never clamped,
  /// `inflowWithCarryover - currentMonthOutflow` equals the account balance
  /// exactly.
  double get inflowWithCarryover => currentMonthInflow + carryover;

  @override
  List<Object?> get props => [
    currentMonthInflow,
    currentMonthOutflow,
    carryover,
  ];
}
