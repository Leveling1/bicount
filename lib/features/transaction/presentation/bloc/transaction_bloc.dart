import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/domain/entities/user.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<CreateTransactionEvent>(_onCreateTransaction);
  }

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
}
