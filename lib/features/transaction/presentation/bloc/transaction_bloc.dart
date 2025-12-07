import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/domain/entities/user.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<AddSubscriptionEvent>(_onAddSubscription);
    on<UnsubscribeEvent>(_onUnsubscribe);
  }

  // Add transaction
  Future<void> _onCreateTransaction(
      CreateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    try {
      // Validation
      if (event.transaction['beneficiaryList']?.isEmpty ?? true) {
        emit(TransactionError(MessageFailure(message: 'Aucun bénéficiaire spécifié')));
        return;
      }

      // Exécution
      await repository.createTransaction(event.transaction);

      // Succès
      emit(TransactionCreated());

    } on MessageFailure catch (e) {
      emit(TransactionError(e));
    } on Failure catch (e) {
      emit(TransactionError(e));
    } catch (e) {
      emit(TransactionError(UnknownFailure()));
    }
  }

  // Add subscription
  Future<void> _onAddSubscription(
      AddSubscriptionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(SubscriptionLoading());

    try {
      // Exécution
      await repository.addSubscription(event.subscription);

      // Succès
      emit(SubscriptionAdded());

    } on MessageFailure catch (e) {
      emit(SubscriptionError(e.message));
    } catch (e) {
      emit(SubscriptionError('An unexpected error occurred.'));
    }
  }

  // Unsubscribe
  Future<void> _onUnsubscribe(
      UnsubscribeEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(UnsubscriptionLoading());

    try {
      // Exécution
      await repository.unsubscribe(event.subscription);

      // Succès
      emit(UnsubscriptionSuccess());

    } on MessageFailure catch (e) {
      emit(SubscriptionError(e.message));
    } catch (e) {
      emit(SubscriptionError('An unexpected error occurred.'));
    }
  }
}
