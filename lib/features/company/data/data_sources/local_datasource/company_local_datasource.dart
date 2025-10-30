import 'dart:async';

import '../../models/company.model.dart';

abstract class CompanyLocalDataSource {
  Stream<List<CompanyModel>> getCompany ();
}
