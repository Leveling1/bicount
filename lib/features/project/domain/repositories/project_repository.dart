

import 'dart:io';

import '../entities/project_model.dart';

abstract class ProjectRepository {
  Future<ProjectEntity> createProject(ProjectEntity project, File? logoFile);
}
