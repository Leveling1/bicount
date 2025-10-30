import 'dart:io';

import 'package:bicount/features/company/domain/entities/company.dart';

import '../../../group/domain/entities/group_model.dart';
import '../../data/models/company.model.dart';

abstract class CompanyRepository {
  Future<CompanyEntity> createCompany(CompanyEntity company, File? logoFile);
  Stream<List<CompanyModel>> getCompanyStream();
  Stream<CompanyEntity> getCompanyDetailStream(CompanyModel company);
}
