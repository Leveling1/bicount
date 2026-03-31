import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/repositories/salary_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'salary_event.dart';
part 'salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  SalaryBloc(this.repository) : super(const SalaryIdle()) {
    on<SalaryOccurrenceConfirmRequested>(_onConfirmRequested);
    on<SalaryAutomaticModeRequested>(_onAutomaticModeRequested);
  }

  final SalaryRepository repository;

  Future<void> _onConfirmRequested(
    SalaryOccurrenceConfirmRequested event,
    Emitter<SalaryState> emit,
  ) async {
    emit(SalaryActionInProgress(targetId: event.occurrence.occurrenceId));
    try {
      await repository.confirmSalaryOccurrence(event.occurrence);
      emit(
        const SalaryActionSuccess(message: 'salary_payment_confirmed_success'),
      );
    } on MessageFailure catch (error) {
      emit(SalaryActionFailure(message: error.message));
    } on Failure catch (error) {
      emit(SalaryActionFailure(message: error.message));
    } catch (_) {
      emit(
        const SalaryActionFailure(
          message: 'Unable to confirm this salary payment right now.',
        ),
      );
    }
  }

  Future<void> _onAutomaticModeRequested(
    SalaryAutomaticModeRequested event,
    Emitter<SalaryState> emit,
  ) async {
    emit(
      SalaryActionInProgress(
        targetId: event.occurrence.recurringFunding.recurringFundingId,
      ),
    );
    try {
      await repository.continueSalaryAutomatically(event.occurrence);
      emit(
        const SalaryActionSuccess(
          message: 'salary_automatic_mode_enabled_success',
        ),
      );
    } on MessageFailure catch (error) {
      emit(SalaryActionFailure(message: error.message));
    } on Failure catch (error) {
      emit(SalaryActionFailure(message: error.message));
    } catch (_) {
      emit(
        const SalaryActionFailure(
          message: 'Unable to update this salary tracking right now.',
        ),
      );
    }
  }
}
