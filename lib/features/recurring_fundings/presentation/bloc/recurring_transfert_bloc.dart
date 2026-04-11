import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/recurring_fundings/domain/repositories/recurring_transfert_repository.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringTransfertBloc
    extends Bloc<RecurringTransfertEvent, RecurringTransfertState> {
  RecurringTransfertBloc(this.repository)
    : super(const RecurringTransfertIdle()) {
    on<UpdateRecurringPlanRequested>(_onUpdateRequested);
    on<TerminateRecurringPlanRequested>(_onTerminateRequested);
    on<DeleteRecurringPlanRequested>(_onDeleteRequested);
    on<ConfirmSalaryOccurrenceRequested>(_onConfirmRequested);
    on<ContinueSalaryAutomaticallyRequested>(_onContinueAutomaticRequested);
  }

  final RecurringTransfertRepository repository;

  Future<void> _onUpdateRequested(
    UpdateRecurringPlanRequested event,
    Emitter<RecurringTransfertState> emit,
  ) async {
    emit(
      RecurringTransfertActionInProgress(
        targetId: event.request.recurringTransfertId,
      ),
    );
    try {
      await repository.updateRecurringTransfert(event.request);
      emit(
        RecurringTransfertActionSuccess(
          targetId: event.request.recurringTransfertId,
          message: 'Recurring plan updated.',
        ),
      );
    } on Failure catch (error) {
      emit(RecurringTransfertActionFailure(message: error.message));
    }
  }

  Future<void> _onTerminateRequested(
    TerminateRecurringPlanRequested event,
    Emitter<RecurringTransfertState> emit,
  ) async {
    final targetId = event.recurringTransfert.recurringTransfertId ?? '';
    emit(RecurringTransfertActionInProgress(targetId: targetId));
    try {
      await repository.terminateRecurringTransfert(event.recurringTransfert);
      emit(
        RecurringTransfertActionSuccess(
          targetId: targetId,
          message: 'Recurring plan stopped.',
        ),
      );
    } on Failure catch (error) {
      emit(RecurringTransfertActionFailure(message: error.message));
    }
  }

  Future<void> _onDeleteRequested(
    DeleteRecurringPlanRequested event,
    Emitter<RecurringTransfertState> emit,
  ) async {
    final targetId = event.recurringTransfert.recurringTransfertId ?? '';
    emit(RecurringTransfertActionInProgress(targetId: targetId));
    try {
      await repository.deleteRecurringTransfert(event.recurringTransfert);
      emit(
        RecurringTransfertActionSuccess(
          targetId: targetId,
          message: 'Recurring plan deleted.',
        ),
      );
    } on Failure catch (error) {
      emit(RecurringTransfertActionFailure(message: error.message));
    }
  }

  Future<void> _onConfirmRequested(
    ConfirmSalaryOccurrenceRequested event,
    Emitter<RecurringTransfertState> emit,
  ) async {
    emit(
      RecurringTransfertActionInProgress(
        targetId: event.occurrence.occurrenceId,
      ),
    );
    try {
      await repository.confirmSalaryOccurrence(
        event.occurrence,
        confirmedAmount: event.confirmedAmount,
      );
      emit(
        RecurringTransfertActionSuccess(
          targetId: event.occurrence.occurrenceId,
          message: 'Recurring salary confirmed.',
        ),
      );
    } on Failure catch (error) {
      emit(RecurringTransfertActionFailure(message: error.message));
    }
  }

  Future<void> _onContinueAutomaticRequested(
    ContinueSalaryAutomaticallyRequested event,
    Emitter<RecurringTransfertState> emit,
  ) async {
    final targetId =
        event.occurrence.recurringTransfert.recurringTransfertId ?? '';
    emit(RecurringTransfertActionInProgress(targetId: targetId));
    try {
      await repository.confirmSalaryOccurrence(
        event.occurrence,
        confirmedAmount: event.confirmedAmount,
        switchToAutomatic: true,
      );
      emit(
        RecurringTransfertActionSuccess(
          targetId: targetId,
          message: 'Recurring salary switched to automatic mode.',
        ),
      );
    } on Failure catch (error) {
      emit(RecurringTransfertActionFailure(message: error.message));
    }
  }
}
