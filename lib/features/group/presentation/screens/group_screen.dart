import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

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
