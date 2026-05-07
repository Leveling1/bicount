import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'debt_event.dart';
part 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  DebtBloc(this.repository) : super(const DebtIdle()) {
    on<RecordDebtPaymentRequested>(_onRecordDebtPaymentRequested);
  }

  final DebtRepository repository;

  Future<void> _onRecordDebtPaymentRequested(
    RecordDebtPaymentRequested event,
    Emitter<DebtState> emit,
  ) async {
    emit(DebtActionInProgress(targetId: event.request.debtId));
    try {
      await repository.recordDebtPayment(event.request);
      emit(
        DebtActionSuccess(
          targetId: event.request.debtId,
          message: 'Debt payment recorded.',
        ),
      );
    } on Failure catch (error) {
      emit(DebtActionFailure(message: error.message));
    }
  }
}
