part of 'company_bloc.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyCreated extends CompanyState {}

class CompanyError extends CompanyState {
  final Failure failure;

  CompanyError(this.failure);
}

class CompanyLoaded extends CompanyState {
  final List<CompanyModel> companies;

  CompanyLoaded(this.companies);
}
