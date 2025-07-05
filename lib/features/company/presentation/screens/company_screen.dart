import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/company_bloc.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColorDark,
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          return const Center(child: Text('Company Screen'));
        },
      ),
    );
  }
}
