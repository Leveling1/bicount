import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/project_model.dart';
import '../../domain/repositories/project_repository.dart';
part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository repository;
  ProjectBloc(this.repository) : super(ProjectInitial()) {
    on<CreateProjectEvent>(_onCreateGroup);
  }

  Future<void> _onCreateGroup(CreateProjectEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final createdGroup =
      await repository.createProject(event.project, event.logoFile);
      emit(ProjectCreated(createdGroup));
    } catch (e) {
      emit(ProjectError(e is Failure ? e : UnknownFailure()));
    }
  }
}
