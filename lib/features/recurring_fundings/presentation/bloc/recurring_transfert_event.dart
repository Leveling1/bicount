import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/update_recurring_transfert_request_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

sealed class RecurringTransfertEvent {
  const RecurringTransfertEvent();
}

class UpdateRecurringPlanRequested extends RecurringTransfertEvent {
  const UpdateRecurringPlanRequested(this.request);

  final UpdateRecurringTransfertRequestEntity request;
}

class TerminateRecurringPlanRequested extends RecurringTransfertEvent {
  const TerminateRecurringPlanRequested(this.recurringTransfert);

  final RecurringTransfertModel recurringTransfert;
}

class DeleteRecurringPlanRequested extends RecurringTransfertEvent {
  const DeleteRecurringPlanRequested(this.recurringTransfert);

  final RecurringTransfertModel recurringTransfert;
}

class ConfirmSalaryOccurrenceRequested extends RecurringTransfertEvent {
  const ConfirmSalaryOccurrenceRequested({
    required this.occurrence,
    required this.confirmedAmount,
  });

  final SalaryOccurrenceEntity occurrence;
  final double confirmedAmount;
}

class ContinueSalaryAutomaticallyRequested extends RecurringTransfertEvent {
  const ContinueSalaryAutomaticallyRequested({
    required this.occurrence,
    required this.confirmedAmount,
  });

  final SalaryOccurrenceEntity occurrence;
  final double confirmedAmount;
}
