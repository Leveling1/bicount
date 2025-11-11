import 'dart:io';

import 'package:bicount/features/company/domain/entities/company.dart';
import '../../data/models/company.model.dart';

abstract class CompanyRepository {
  Future<CompanyEntity> createCompany(CompanyEntity company, File? logoFile);
  Stream<List<CompanyModel>> getCompanyStream();
  Stream<CompanyEntity> getCompanyDetailStream(String cid);
}
