import 'package:bicount/features/project/domain/entities/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/project_bloc.dart';

class ProjectScreen extends StatelessWidget {
  final ProjectEntity projectData;
  const ProjectScreen({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          return const Center(
            child: Text('Project Screen'),
          );
        },
      ),
    );
  }
}
