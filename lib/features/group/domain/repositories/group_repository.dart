import 'dart:io';

import 'package:bicount/features/group/domain/entities/member_model.dart';

import '../entities/group_model.dart';

abstract class GroupRepository {
  Future<GroupModel> createGroup(GroupModel company, File? logoFile);
  Future<List<MemberModel>> getAllGroupDetails(GroupModel group);
}
