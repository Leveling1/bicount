part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final HomeEntity data;
  HomeLoaded(this.data);
}

class HomeNoInternet extends HomeState {
  final String message;
  HomeNoInternet({this.message = "No internet connection"});
}