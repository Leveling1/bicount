import 'dart:io';

import 'package:bicount/features/company/domain/entities/company.dart';
import 'package:bicount/features/company/domain/entities/company_data.dart';


abstract class CompanyRepository {
  Future<CompanyEntity> createCompany(CompanyEntity company, File? logoFile);
  Stream<CompanyData> getCompanyStream();
  Stream<CompanyEntity> getCompanyDetailStream(String cid);
}
