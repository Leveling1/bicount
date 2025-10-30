part of 'detail_bloc.dart';

abstract class DetailEvent {}

// For the company details
class GetCompanyDetail extends DetailEvent {
  CompanyEntity company;
  GetCompanyDetail(this.company);
}

class DetailsDataUpdated extends DetailEvent {
  final CompanyModel companies;
  DetailsDataUpdated(this.companies);
}

class DetailsStreamError extends DetailEvent {
  final dynamic error;
  DetailsStreamError(this.error);
}