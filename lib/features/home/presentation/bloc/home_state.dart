part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final Failure failure;
  HomeError(this.failure);
}

class HomeLoaded extends HomeState {
  final UserModel data;
  HomeLoaded(this.data);
}