import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_search_field.dart';
import '../bloc/list_bloc/list_bloc.dart';
import '../widgets/company_card.dart';
import '../widgets/company_card_skeleton.dart';
import '../widgets/company_large_card.dart';

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
      context.read<ListBloc>().add(GetAllCompany());
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
    return  BlocConsumer<ListBloc, ListState>(
      listener: (context, state) {
        if (state is ListError) {
          NotificationHelper.showFailureNotification(context, state.toString());
        }
      },
      builder: (context, state) {
        if (state is ListLoading) {
          return SingleChildScrollView(
            child: Column(
              children: List.generate(10, (_) => const CompanyCardSkeleton()),
            ),
          );
        } else if (state is ListLoaded) {
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
                  filteredCompanies.map((company) {
                    if (state.companies.length > 10) {
                      return CompanyCard(company: company);
                    } else {
                      return CompanyLargeCard(company: company);
                    }
                  }).toList(),
                )
              ]
            ),
          );
        } else if (state is ListError) {
          return Center(child: Text("Error: ${state.failure.message}"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
