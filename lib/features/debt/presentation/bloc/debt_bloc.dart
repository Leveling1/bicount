import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'debt_event.dart';
part 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  DebtBloc(this.repository) : super(const DebtIdle()) {
    on<UpdateDebtRequested>(_onUpdateDebtRequested);
    on<DeleteDebtRequested>(_onDeleteDebtRequested);
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

  Future<void> _onUpdateDebtRequested(
    UpdateDebtRequested event,
    Emitter<DebtState> emit,
  ) async {
    emit(DebtActionInProgress(targetId: event.request.debtId));
    try {
      await repository.updateDebtContract(event.request);
      emit(
        DebtActionSuccess(
          targetId: event.request.debtId,
          message: 'Debt contract updated.',
        ),
      );
    } on Failure catch (error) {
      emit(DebtActionFailure(message: error.message));
    }
  }

  Future<void> _onDeleteDebtRequested(
    DeleteDebtRequested event,
    Emitter<DebtState> emit,
  ) async {
    emit(DebtActionInProgress(targetId: event.debtId));
    try {
      await repository.deleteDebtContract(event.debtId);
      emit(
        DebtActionSuccess(
          targetId: event.debtId,
          message: 'Debt contract deleted.',
        ),
      );
    } on Failure catch (error) {
      emit(DebtActionFailure(message: error.message));
    }
  }
}
