import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_search_field.dart';
import '../../domain/entities/company_model.dart';
import '../bloc/company_bloc.dart';
import '../widgets/company_card.dart';
import '../widgets/company_card_skeleton.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ici on déclenche la récupération des companies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyBloc>().add(GetAllCompany());
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state is CompanyError) {
          NotificationHelper.showFailureNotification(context, state.toString());
        }
      },
      builder: (context, state) {
        if (state is CompanyLoading) {
          return SingleChildScrollView(
            child: Column(
              children: List.generate(10, (_) => const CompanyCardSkeleton()),
            ),
          );
        } else if (state is CompanyLoaded) {
          if (state.companies.isEmpty) {
            return const Center(child: Text("You are not linked to any company."));
          }

          final filteredCompanies = state.companies.where((company) {
            final query = _searchController.text.toLowerCase();
            return company.name.toLowerCase().contains(query);
          }).toList();

          filteredCompanies.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return SingleChildScrollView(
            child: Column(
              children: [
                state.companies.length > 10
                  ? CustomSearchField(
                      onChanged: (value){
                        setState(() {
                          _searchController.text = value;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
                const SizedBox(height: 20),
                Column(
                  children:
                  filteredCompanies.map((company) => CompanyCard(company: company)).toList(),
                )
              ]
            ),
          );
        } else if (state is CompanyError) {
          return Center(child: Text("Error: ${state.failure.message}"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
