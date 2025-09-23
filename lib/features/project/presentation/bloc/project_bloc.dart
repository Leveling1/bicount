import 'package:flutter_bloc/flutter_bloc.dart';
part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    // Add your event handlers here
  }
}
