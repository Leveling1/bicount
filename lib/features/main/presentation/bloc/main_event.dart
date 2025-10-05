part of 'main_bloc.dart';

abstract class MainEvent {}

class NetworkStatusChanged extends MainEvent {
  final NetworkStatus status;
  NetworkStatusChanged(this.status);
}

class GetAllStartData extends MainEvent {}