import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/recurring_fundings/data/data_sources/local_datasource/recurring_transfert_local_datasource.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/update_recurring_transfert_request_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/repositories/recurring_transfert_repository.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

class RecurringTransfertRepositoryImpl implements RecurringTransfertRepository {
  RecurringTransfertRepositoryImpl({required this.localDataSource});

  final RecurringTransfertLocalDataSource localDataSource;

  @override
  Future<void> updateRecurringTransfert(
    UpdateRecurringTransfertRequestEntity request,
  ) async {
    try {
      await localDataSource.updateRecurringTransfert(request);
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to update this recurring plan right now.',
      );
    }
  }

  @override
  Future<void> terminateRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    try {
      await localDataSource.terminateRecurringTransfert(recurringTransfert);
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to stop this recurring plan right now.',
      );
    }
  }

  @override
  Future<void> deleteRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    try {
      await localDataSource.deleteRecurringTransfert(recurringTransfert);
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to delete this recurring plan right now.',
      );
    }
  }

  @override
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence, {
    required double confirmedAmount,
    bool switchToAutomatic = false,
  }) async {
    try {
      await localDataSource.confirmSalaryOccurrence(
        occurrence,
        confirmedAmount: confirmedAmount,
        switchToAutomatic: switchToAutomatic,
      );
    } catch (_) {
      throw MessageFailure(
        message: switchToAutomatic
            ? 'Unable to update this recurring salary right now.'
            : 'Unable to confirm this recurring salary right now.',
      );
    }
  }
}
