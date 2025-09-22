import 'dart:io';

import 'package:bicount/features/company/domain/entities/company_model.dart';

import '../entities/company_group_model.dart';

abstract class CompanyRepository {
  Future<CompanyModel> createCompany(CompanyModel company, File? logoFile);
  Future<CompanyGroupModel> createCompanyGroup(CompanyGroupModel company, File? logoFile);
  Stream<List<CompanyModel>> getCompanyStream();
}
