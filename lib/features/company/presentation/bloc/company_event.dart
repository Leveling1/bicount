part of 'company_bloc.dart';

abstract class CompanyEvent {}

class CreateCompanyEvent extends CompanyEvent {
  final CompanyModel company;
  final File? logoFile;
  CreateCompanyEvent(this.company, {this.logoFile});
}

// Add your events here
class ExampleCompanyEvent extends CompanyEvent {}

class GetAllCompanyRequested extends CompanyEvent {}
