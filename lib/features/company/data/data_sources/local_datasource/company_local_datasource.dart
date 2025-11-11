import 'dart:async';

import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';

import '../../../../group/data/models/group.model.dart';
import '../../../../project/data/models/project.model.dart';
import '../../models/company.model.dart';

abstract class CompanyLocalDataSource {
  Stream<List<CompanyModel>> getCompany();
  Stream<List<CompanyWithUserLinkModel>> getCompanyLinks();
  Stream<CompanyModel> getCompanyDetails(String cid);
  Stream<List<ProjectModel>> getCompanyProjects(String cid);
  Stream<List<GroupModel>> getCompanyGroups(String cid);
}
