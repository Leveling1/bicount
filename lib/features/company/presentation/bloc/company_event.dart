part of 'company_bloc.dart';

abstract class CompanyEvent {}

class CreateCompanyEvent extends CompanyEvent {
  final CompanyEntity company;
  final File? logoFile;
  CreateCompanyEvent(this.company, {this.logoFile});
}

class ExampleCompanyEvent extends CompanyEvent {}


// For stream app with screen
class GetAllCompany extends CompanyEvent {}