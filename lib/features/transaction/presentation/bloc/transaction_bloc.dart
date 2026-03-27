import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
  }

  final TransactionRepository repository;

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    try {
      if (event.transaction.splits.isEmpty) {
        emit(
          TransactionError(
            MessageFailure(message: 'Add at least one beneficiary.'),
          ),
        );
        return;
      }

      await repository.createTransaction(event.transaction);
      emit(TransactionCreated());
    } on MessageFailure catch (error) {
      emit(TransactionError(error));
    } on Failure catch (error) {
      emit(TransactionError(error));
    } catch (_) {
      emit(TransactionError(UnknownFailure()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    try {
      if (event.transaction.splits.isEmpty) {
        emit(
          TransactionError(
            MessageFailure(message: 'Add at least one beneficiary.'),
          ),
        );
        return;
      }

      await repository.updateTransaction(
        event.previousTransaction,
        event.transaction,
      );
      emit(TransactionUpdated());
    } on MessageFailure catch (error) {
      emit(TransactionError(error));
    } on Failure catch (error) {
      emit(TransactionError(error));
    } catch (_) {
      emit(TransactionError(UnknownFailure()));
    }
  }

}
