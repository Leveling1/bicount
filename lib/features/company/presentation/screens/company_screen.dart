import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_search_field.dart';
import '../bloc/list_bloc/list_bloc.dart';
import '../widgets/company_card.dart';
import '../widgets/company_card_skeleton.dart';
import '../widgets/company_large_card.dart';

class CompanyScreen extends StatefulWidget {
  final bool showSearchBar;
  final TextEditingController searchController;

  const CompanyScreen({
    super.key,
    this.showSearchBar = false,
    required this.searchController,
  });

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  @override
  void initState() {
    super.initState();
    // Ici on déclenche la récupération des companies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListBloc>().add(GetAllCompany());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showSearchBar) {
      widget.searchController.clear();
    }
    return BlocConsumer<ListBloc, ListState>(
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
          if (state.companies.companies.isEmpty) {
            return const Center(
              child: Text("You are not linked to any company."),
            );
          }

          final filteredCompanies = state.companies.companies.where((company) {
            final query = widget.searchController.text.toLowerCase();
            return company.name.toLowerCase().contains(query);
          }).toList();

          filteredCompanies.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: Column(
                children: [
                  ...filteredCompanies.map((company) {
                    if (state.companies.companies.length > 10) {
                      return CompanyCard(company: company);
                    } else {
                      final roleModel =
                          state.companies.links
                              .where((e) => e.companyId == company.cid)
                              .isEmpty
                          ? null
                          : state.companies.links.firstWhere(
                              (e) => e.companyId == company.cid,
                            );
                      final role = roleModel?.role ?? '';
                      return CompanyLargeCard(company: company, role: role);
                    }
                  }),
                  SizedBox(height: 50.h),
                ],
              ),
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
