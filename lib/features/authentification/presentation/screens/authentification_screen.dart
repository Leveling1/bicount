import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentification_bloc.dart';

class AuthentificationScreen extends StatelessWidget {
  const AuthentificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthentificationBloc, AuthentificationState>(
        builder: (context, state) {
          return const Center(
            child: Text('Authentification Screen'),
          );
        },
      ),
    );
  }
}
