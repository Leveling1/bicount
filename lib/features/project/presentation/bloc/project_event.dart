part of 'project_bloc.dart';

abstract class ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final ProjectEntity project;
  final File? logoFile;
  CreateProjectEvent(this.project, {this.logoFile});
}