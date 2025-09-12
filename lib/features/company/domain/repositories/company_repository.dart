import 'dart:io';

import 'package:bicount/features/company/domain/entities/company_model.dart';

abstract class CompanyRepository {
  Future<CompanyModel> createCompany(CompanyModel company, File? logoFile);
  Stream<List<CompanyModel>> getCompanyStream();
  Future<void> disconnect();
}
