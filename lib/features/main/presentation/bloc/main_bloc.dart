import 'dart:async';

import 'package:bicount/core/constants/network_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/main_entity.dart';
import '../../domain/repositories/main_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc(this.repository) : super(MainInitial()) {
    on<GetAllStartData>(_onGetAllStartData);
    on<RefreshMainData>(_onRefreshMainData);
    on<_StartDataUpdated>(_onStartDataUpdated);
    on<_StartDataFailed>(_onStartDataFailed);
  }

  final MainRepository repository;
  StreamSubscription<MainEntity>? _startDataSubscription;

  Future<void> _onGetAllStartData(
    GetAllStartData event,
    Emitter<MainState> emit,
  ) async {
    try {
      emit(MainLoading());
      await _startDataSubscription?.cancel();
      await repository.reconcileDeletedRecords();
      _startDataSubscription = repository.getStartDataStream().listen(
        (data) => add(_StartDataUpdated(data)),
        onError: (error, _) => add(_StartDataFailed(error.toString())),
      );
    } catch (error) {
      emit(MainError(error.toString()));
    }
  }

  void _onStartDataUpdated(_StartDataUpdated event, Emitter<MainState> emit) {
    emit(MainLoaded(event.data));
  }

  Future<void> _onRefreshMainData(
    RefreshMainData event,
    Emitter<MainState> emit,
  ) async {
    try {
      await repository.forceHydrate();
    } catch (_) {
      // Hydration failure is non-fatal; realtime will catch up.
    }
  }

  void _onStartDataFailed(_StartDataFailed event, Emitter<MainState> emit) {
    emit(MainError(event.message));
  }

  @override
  Future<void> close() async {
    await _startDataSubscription?.cancel();
    return super.close();
  }
}
