import 'package:bicount/core/constants/network_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/main_entity.dart';
import '../../domain/repositories/main_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc(this.repository) : super(MainInitial()) {
    on<GetAllStartData>(_onGetAllStartData);
  }

  final MainRepository repository;

  Future<void> _onGetAllStartData(
    GetAllStartData event,
    Emitter<MainState> emit,
  ) async {
    try {
      await repository.reconcileDeletedRecords();
      await emit.forEach<MainEntity>(
        repository.getStartDataStream(),
        onData: MainLoaded.new,
        onError: (error, stackTrace) => MainError(error.toString()),
      );
    } catch (error) {
      emit(MainError(error.toString()));
    }
  }
}
