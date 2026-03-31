import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_plan_summary_entity.dart';
import 'package:equatable/equatable.dart';

class SalaryDashboardEntity extends Equatable {
  const SalaryDashboardEntity({
    required this.plans,
    required this.attentionOccurrences,
    required this.recentReceivedOccurrences,
    required this.dueTodayAmount,
    required this.overdueAmount,
    required this.dueTodayCount,
    required this.overdueCount,
    required this.nextExpectedDate,
  });

  final List<SalaryPlanSummaryEntity> plans;
  final List<SalaryOccurrenceEntity> attentionOccurrences;
  final List<SalaryOccurrenceEntity> recentReceivedOccurrences;
  final double dueTodayAmount;
  final double overdueAmount;
  final int dueTodayCount;
  final int overdueCount;
  final DateTime? nextExpectedDate;

  bool get hasPlans => plans.isNotEmpty;
  bool get hasAttention => attentionOccurrences.isNotEmpty;
  double get totalOutstandingAmount => dueTodayAmount + overdueAmount;

  @override
  List<Object?> get props => [
    plans,
    attentionOccurrences,
    recentReceivedOccurrences,
    dueTodayAmount,
    overdueAmount,
    dueTodayCount,
    overdueCount,
    nextExpectedDate,
  ];
}
