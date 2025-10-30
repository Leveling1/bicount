part of 'detail_bloc.dart';

abstract class DetailState {}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final CompanyEntity company;
  DetailLoaded(this.company);
}
class DetailError extends DetailState {
  final Failure failure;
  DetailError(this.failure);
}
