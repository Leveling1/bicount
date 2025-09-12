import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_helper.dart';
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
  void initState() {
    super.initState();
    // Ici on déclenche la récupération des companies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyBloc>().add(GetAllCompany());
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CompanyModel> companies = [];
    List<CompanyModel> filteredCompanies = [];
    return  BlocConsumer<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state is CompanyError) {
          NotificationHelper.showFailureNotification(context, state.toString());
        }
      },
      builder: (context, state) {
        if (state is CompanyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CompanyLoaded) {
          if (state.companies.isEmpty) {
            return const Center(child: Text("You are not linked to any company."));
          }
          return ListView.builder(
            itemCount: state.companies.length,
            itemBuilder: (context, index) {
              final company = state.companies[index];
              return ListTile(title: CompanyCard(company: company));
            },
          );
        } else if (state is CompanyError) {
          return Center(child: Text("Error: ${state.failure.message}"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
