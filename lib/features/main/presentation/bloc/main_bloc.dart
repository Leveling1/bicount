import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/main_entity.dart';
import '../../domain/repositories/main_repository.dart';
part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final MainRepository repository;

  MainBloc(this.repository) : super(MainInitial()) {
    on<GetAllStartData>(_onGetAllStartData);
  }

  void _onGetAllStartData(
      GetAllStartData event, Emitter<MainState> emit) async {
    try {
      // Écoute le stream Realtime
      await emit.forEach<MainEntity>(
        repository.getStartDataStream(),
        onData: (data) {
          return MainLoaded(data);
        },
        onError: (error, stackTrace) =>
            MainError(error.toString()),
      );
    } catch (e) {
      emit(MainError(e.toString()));
    }
  }
}
