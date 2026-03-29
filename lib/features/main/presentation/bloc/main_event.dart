part of 'main_bloc.dart';

abstract class MainEvent {}

class NetworkStatusChanged extends MainEvent {
  final NetworkStatus status;
  NetworkStatusChanged(this.status);
}

class GetAllStartData extends MainEvent {}

class _StartDataUpdated extends MainEvent {
  _StartDataUpdated(this.data);

  final MainEntity data;
}

class _StartDataFailed extends MainEvent {
  _StartDataFailed(this.message);

  final String message;
}
