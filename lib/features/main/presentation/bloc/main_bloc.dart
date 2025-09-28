import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/main_repository_impl.dart';
import '../../domain/repositories/main_repository.dart';
part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final MainRepository repository;
  late final StreamSubscription _networkSub;

  MainBloc(this.repository) : super(MainInitial()) {
    on<NetworkStatusChanged>(_onNetworkStatusChanged);

    _networkSub = repository.networkStatus.listen((status) {
      add(NetworkStatusChanged(status));
    });
  }

  void _onNetworkStatusChanged(
      NetworkStatusChanged event, Emitter<MainState> emit) {
    if (state is MainStateConnexion) {
      emit((state as MainStateConnexion).copyWith(networkStatus: event.status));
    } else {
      emit(MainStateConnexion(networkStatus: event.status));
    }
  }

  @override
  Future<void> close() {
    _networkSub.cancel();
    if (repository is MainRepositoryImpl) {
      (repository as MainRepositoryImpl).dispose();
    }
    return super.close();
  }
}
