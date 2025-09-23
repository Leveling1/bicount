import 'dart:io';

import '../entities/group_model.dart';

abstract class GroupRepository {
  Future<GroupModel> createGroup(GroupModel company, File? logoFile);
}
