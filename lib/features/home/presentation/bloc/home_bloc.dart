import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/data/models/user_model.dart';
import '../../domain/repositories/home_repository.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  UserModel? _cachedData;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<GetAllData>(_getAllData);
  }

  Future<void> _getAllData(
      GetAllData event, Emitter<HomeState> emit) async {

    // Émettre directement le cache si disponible
    if (_cachedData != null) {
      emit(HomeLoaded(_cachedData!));
      return;
    }

    emit(HomeLoading());
    try {
      // Écoute le stream Realtime
      await emit.forEach<UserModel>(
        repository.getDataStream(),
        onData: (companies) {
          // Mettre à jour le cache interne
          _cachedData = companies;
          return HomeLoaded(companies);
        },
        onError: (error, stackTrace) =>
            HomeError(ServerFailure(error.toString())),
      );
    } catch (e) {
      emit(HomeError(ServerFailure(e.toString())));
    }
  }
}
