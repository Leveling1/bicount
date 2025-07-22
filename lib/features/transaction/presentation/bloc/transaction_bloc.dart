import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/domain/entities/user.dart';
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
        await repository.createTransaction(event.transaction);
        emit(TransactionCreated());
        add(GetAllTransactionsRequested());
      } catch (e) {
        emit(TransactionError(e is Failure ? e : UnknownFailure()));
      }
    });
    on<GetAllTransactionsRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await repository.getAllTransactions();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError(e is Failure ? e : UnknownFailure()));
      }
    });
    on<GetLinkedUsersRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final users = await repository.getLinkedUsers();
        emit(TransactionLinkedUsersLoaded(users));
      } catch (e) {
        emit(TransactionError(e is Failure ? e : UnknownFailure()));
      }
    });
  }
}
