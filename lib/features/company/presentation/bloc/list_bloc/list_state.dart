part of 'list_bloc.dart';

abstract class ListState {}

class ListInitial extends ListState {}

class ListLoading extends ListState {}

// For the creation of a company
class ListCreated extends ListState {
  final CompanyEntity company;
  ListCreated(this.company);
}

class ListLoaded extends ListState {
  final CompanyData companies;
  ListLoaded(this.companies);
}
class ListError extends ListState {
  final Failure failure;
  ListError(this.failure);
}