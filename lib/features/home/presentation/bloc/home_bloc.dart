import 'package:bicount/features/home/domain/entities/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/data/models/user.model.dart';
import '../../domain/repositories/home_repository.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<GetAllData>(_getAllData);
  }

  Future<void> _getAllData(GetAllData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // Écoute le stream Realtime
      await emit.forEach<HomeEntity>(
        repository.getDataStream(),
        onData: (userData) {
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
