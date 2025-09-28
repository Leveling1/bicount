import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_model.dart';
import '../bloc/group_bloc.dart';

class GroupScreen extends StatelessWidget {
  final GroupModel groupData;
  const GroupScreen({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          return const Center(
            child: Text('Group Screen'),
          );
        },
      ),
    );
  }
}
