import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class CompanyWithUserLinkModel extends OfflineModel {
  final String companyId;

  final String userId;

  final String role;

  final String? lid;

  CompanyWithUserLinkModel({
    String? lid,
    required this.companyId,
    required this.userId,
    required this.role,
  }) : lid = lid ?? const Uuid().v4(),
       super();
}
