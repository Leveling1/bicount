import 'dart:async';

import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';
import 'package:bicount/features/notification/presentation/services/notification_permission_service.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this.repository, {this.permissionService})
    : super(TransactionInitial()) {
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
  }

  final TransactionRepository repository;
  final NotificationPermissionService? permissionService;

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
      _requestPermissionForCreatedTransaction(event.transaction);
    } on MessageFailure catch (error) {
      emit(TransactionError(error));
    } on Failure catch (error) {
      emit(TransactionError(error));
    } catch (_) {
      emit(TransactionError(UnknownFailure()));
    }
  }

  void _requestPermissionForCreatedTransaction(
    CreateTransactionRequestEntity transaction,
  ) {
    final service = permissionService;
    if (service == null) {
      return;
    }
    if (transaction.isDebt) {
      unawaited(
        _requestPermissionAfterFormCloses(
          service,
          NotifiableAction.debtRecorded,
        ),
      );
      return;
    }
    if (transaction.isRecurring &&
        transaction.transactionType == TransactionTypes.salaryCode) {
      unawaited(
        _requestPermissionAfterFormCloses(
          service,
          NotifiableAction.salaryRecorded,
        ),
      );
    }
  }

  // The transaction form closes itself right after this state is emitted,
  // via its own post-frame Navigator.pop(). Waiting here for that closing
  // transition to finish — instead of racing it with an immediate second
  // screen — is what keeps the two navigations from visually overlapping.
  Future<void> _requestPermissionAfterFormCloses(
    NotificationPermissionService service,
    NotifiableAction action,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await service.requestForAction(action);
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    try {
      await repository.deleteTransaction(event.transaction);
      emit(TransactionDeleted());
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
