import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';
import 'package:equatable/equatable.dart';

class CompanyData extends Equatable {
  final List<CompanyModel> companies;
  final List<CompanyWithUserLinkModel> links;

  const CompanyData({required this.companies, required this.links});

  @override
  List<Object?> get props => [companies, links];

  factory CompanyData.fromEmpty() {
    return CompanyData(
      companies: [],
      links: [],
    );
  }
}