import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<CreateTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        repository.addTransaction();
        emit(TransactionSuccess());
      } catch (e) {
        emit(TransactionFailure(e is Failure ? e : UnknownFailure()));
      }
    });
  }
}
