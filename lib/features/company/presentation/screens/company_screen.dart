import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/custom_search_field.dart';
import '../../domain/entities/company_model.dart';
import '../bloc/company_bloc.dart';
import '../widgets/company_card.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<CompanyModel> companies = [];
    List<CompanyModel> filteredCompanies = [];
    return  BlocBuilder<CompanyBloc, CompanyState>(
      builder: (context, state) {
        return companies.isNotEmpty ? Column(
          children: [
            companies.length > 5 ? CustomSearchField(
              onChanged: (value) {
                setState(() {
                  _searchController.text = value;
                });
              },
            ) : const SizedBox.shrink(),
            filteredCompanies.isNotEmpty ? SingleChildScrollView(
              child: Column(
                children: companies.asMap().entries.map((entry) {
                  CompanyModel company = entry.value;
                  return CompanyCard(
                    company: company,
                  );
                }).toList(),
              ),
            ) : Expanded(
              child: const Center(
                child: Text('You are not linked to any company.'),
              ),
            )
          ],
        ) : const Center(
          child: Text('You are not linked to any company.'),
        );
      },
    );
  }
}
