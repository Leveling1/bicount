
import 'dart:async';
import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';

abstract class CompanyRemoteDataSource {
  void subscribeDeleteChanges();
}
