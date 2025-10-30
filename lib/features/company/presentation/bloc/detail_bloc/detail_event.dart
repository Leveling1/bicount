part of 'detail_bloc.dart';

abstract class DetailEvent {}

// For the company details
class GetCompanyDetail extends DetailEvent {
  String cid;
  GetCompanyDetail(this.cid);
}

class DetailsDataUpdated extends DetailEvent {
  final CompanyEntity companies;
  DetailsDataUpdated(this.companies);
}

class DetailsStreamError extends DetailEvent {
  final dynamic error;
  DetailsStreamError(this.error);
}