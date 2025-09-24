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

// For the company details
class CompanyDetailLoading extends CompanyState {}

class CompanyDetailLoaded extends CompanyState {
  final CompanyModel company;
  CompanyDetailLoaded(this.company);
}
class CompanyDetailError extends CompanyState {
  final Failure failure;
  CompanyDetailError(this.failure);
}
