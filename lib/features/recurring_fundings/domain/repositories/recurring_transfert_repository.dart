import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/update_recurring_transfert_request_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

abstract class RecurringTransfertRepository {
  Future<void> updateRecurringTransfert(
    UpdateRecurringTransfertRequestEntity request,
  );
  Future<void> terminateRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  );
  Future<void> deleteRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  );
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence, {
    required double confirmedAmount,
    bool switchToAutomatic = false,
  });
}
