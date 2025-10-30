
import 'dart:async';

import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';
import '../../models/company.model.dart';

abstract class CompanyLocalDataSource {
  Stream<List<CompanyWithUserLinkModel>> getCompanyLink ();
  Stream<List<CompanyModel>> getCompany (Stream<List<CompanyWithUserLinkModel>> companyLinks);
}
