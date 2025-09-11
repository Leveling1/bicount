import 'dart:io';

import 'package:bicount/features/company/domain/entities/company_model.dart';

abstract class CompanyRepository {
  Future<void> createCompany(CompanyModel company, File? logoFile);
}
