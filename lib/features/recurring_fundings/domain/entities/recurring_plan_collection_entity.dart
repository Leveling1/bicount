import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:equatable/equatable.dart';

class RecurringPlanCollectionEntity extends Equatable {
  const RecurringPlanCollectionEntity({
    required this.plans,
    required this.activeCount,
    required this.upcomingCount,
    required this.monthlyReferenceAmount,
    required this.nextExpectedDate,
  });

  final List<RecurringPlanSummaryEntity> plans;
  final int activeCount;
  final int upcomingCount;
  final double monthlyReferenceAmount;
  final DateTime? nextExpectedDate;

  bool get hasPlans => plans.isNotEmpty;

  @override
  List<Object?> get props => [
    plans,
    activeCount,
    upcomingCount,
    monthlyReferenceAmount,
    nextExpectedDate,
  ];
}
