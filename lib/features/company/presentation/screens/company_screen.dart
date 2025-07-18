import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/custom_search_field.dart';
import '../bloc/company_bloc.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<CompanyBloc, CompanyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge/2),
          child: Column(
            children: [
              CustomSearchField(
                onChanged: (value) {
                  setState(() {
                    _searchController.text = value;
                  });
                },
              ),

            ],
          ),
        );
      },
    );
  }
}
