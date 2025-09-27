part of 'list_bloc.dart';

abstract class ListEvent {}

class ExampleCompanyEvent extends ListEvent {}


// For stream app with screen
class GetAllCompany extends ListEvent {}

class ListDataUpdated extends ListEvent {
  final List<CompanyModel> companies;
  ListDataUpdated(this.companies);
}

class ListStreamError extends ListEvent {
  final dynamic error;
  ListStreamError(this.error);
}