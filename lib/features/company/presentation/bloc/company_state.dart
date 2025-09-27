part of 'company_bloc.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

// For the creation of a company
class CompanyCreated extends CompanyState {
  final CompanyModel company;
  CompanyCreated(this.company);
}

class CompanyLoaded extends CompanyState {
  final List<CompanyModel> companies;
  CompanyLoaded(this.companies);
}
class CompanyError extends CompanyState {
  final Failure failure;
  CompanyError(this.failure);
}
