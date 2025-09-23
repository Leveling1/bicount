part of 'project_bloc.dart';

abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectCreated extends ProjectState {
  final ProjectModel project;
  ProjectCreated(this.project);
}

class ProjectError extends ProjectState {
  final Failure failure;
  ProjectError(this.failure);
}

