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

  Future<void> _getAllData(GetAllData event, Emitter<HomeState> emit) async {
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
        onData: (userData) {
          // Mettre à jour le cache interne
          _cachedData = userData;
          return HomeLoaded(userData);
        },
        onError: (error, stackTrace) {
          if (error.toString().contains("No internet")) {
            return HomeNoInternet(message: "No internet connection");
          } else {
            return HomeError(error.toString());
          }
        },
      );
    } catch (e) {
      if (e.toString().contains("No internet")) {
        emit(HomeNoInternet(message: "No internet connection"));
      } else {
        emit(HomeError(e.toString()));
      }
    }
  }
}
