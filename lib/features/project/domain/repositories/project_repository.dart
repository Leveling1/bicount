

import 'dart:io';

import '../entities/project_model.dart';

abstract class ProjectRepository {
  Future<ProjectModel> createProject(ProjectModel project, File? logoFile);
}
