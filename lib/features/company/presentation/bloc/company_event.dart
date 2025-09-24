part of 'company_bloc.dart';

abstract class CompanyEvent {}

class CreateCompanyEvent extends CompanyEvent {
  final CompanyModel company;
  final File? logoFile;
  CreateCompanyEvent(this.company, {this.logoFile});
}

class ExampleCompanyEvent extends CompanyEvent {}


// For stream app with screen
class GetAllCompany extends CompanyEvent {}

class CompanyDataUpdated extends CompanyEvent {
  final List<CompanyModel> companies;
  CompanyDataUpdated(this.companies);
}

class CompanyStreamError extends CompanyEvent {
  final dynamic error;
  CompanyStreamError(this.error);
}

// For the company details
class GetCompanyDetail extends CompanyEvent {
  CompanyModel company;
  GetCompanyDetail(this.company);
}

class CompanyDetailsDataUpdated extends CompanyEvent {
  final CompanyModel companies;
  CompanyDetailsDataUpdated(this.companies);
}

class CompanyDetailsStreamError extends CompanyEvent {
  final dynamic error;
  CompanyDetailsStreamError(this.error);
}