import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  final MainEntity data;
  const ProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Column(
            children: [
              ProfileCard(
                image: 'assets/memoji/memoji_1.png',
                name: data.user.username,
                email: data.user.email,
                onTap: () {}
              )
            ],
          );
        },
      ),
    );
  }
}
