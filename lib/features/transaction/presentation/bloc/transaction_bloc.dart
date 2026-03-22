import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<AddSubscriptionEvent>(_onAddSubscription);
    on<UnsubscribeEvent>(_onUnsubscribe);
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

  Future<void> _onAddSubscription(
    AddSubscriptionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      await repository.addSubscription(event.subscription);
      emit(SubscriptionAdded());
    } on MessageFailure catch (error) {
      emit(SubscriptionError(error.message));
    } on Failure catch (error) {
      emit(SubscriptionError(error.message));
    } catch (_) {
      emit(SubscriptionError('An unexpected error occurred.'));
    }
  }

  Future<void> _onUnsubscribe(
    UnsubscribeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(UnsubscriptionLoading());

    try {
      await repository.unsubscribe(event.subscription);
      emit(UnsubscriptionSuccess());
    } on MessageFailure catch (error) {
      emit(SubscriptionError(error.message));
    } on Failure catch (error) {
      emit(SubscriptionError(error.message));
    } catch (_) {
      emit(SubscriptionError('An unexpected error occurred.'));
    }
  }
}
