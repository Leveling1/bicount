import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/debt_bloc.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DebtBloc, DebtState>(
        builder: (context, state) {
          return const Center(
            child: Text('Debt Screen'),
          );
        },
      ),
    );
  }
}
