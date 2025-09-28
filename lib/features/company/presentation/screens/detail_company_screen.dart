import 'package:bicount/features/company/presentation/screens/share_company.dart';
import 'package:bicount/features/project/presentation/screens/add_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/expandable_text.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../core/widgets/details_card.dart';
import '../../../project/presentation/widgets/project_card.dart';
import '../../domain/entities/company_model.dart';
import '../bloc/detail_bloc/detail_bloc.dart';
import '../widgets/company_card_info.dart';
import '../widgets/company_profil.dart';
import '../widgets/custom_pie_chart.dart';
import '../../../group/presentation/widgets/group_card.dart';
import '../widgets/skeletonBox.dart';
import '../widgets/title_icon_buttom_row.dart';
import '../../../group/presentation/screens/add_group.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailCompanyScreen extends StatefulWidget {
  final CompanyModel company;
  const DetailCompanyScreen({super.key, required this.company});

  @override
  State<DetailCompanyScreen> createState() => _DetailCompanyScreenState();
}

class _DetailCompanyScreenState extends State<DetailCompanyScreen> {
  Widget _spacerHeight() => const SizedBox(height: AppDimens.marginMedium);
  Widget _spacerWidth() => const SizedBox(width: AppDimens.marginMedium);
  late CompanyModel company;

  @override
  void initState() {
    super.initState();
    company = widget.company;
    // Ici on déclenche la récupération des companies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailBloc>().add(GetCompanyDetail(company));
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailBloc, DetailState>(
      listener: (context, state) {
        if (state is DetailError) {
          NotificationHelper.showFailureNotification(context, state.failure.message.toString());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Company info',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  'assets/icons/back_icon.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.titleSmall!.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showCustomBottomSheet(
                    context: context,
                    minHeight: 0.95,
                    color: null,
                    child: ShareCompany(
                      CID: widget.company.CID!,
                    ),
                  );
                },
                icon: Icon(
                  Icons.ios_share_outlined,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  size: 20,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.paddingLarge,
              right: AppDimens.paddingLarge,
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    state is DetailLoading
                    ? SkeletonBox()
                    : state is DetailLoaded
                    ? Column(
                      children: [
                        CompanyProfil(
                          width: 100,
                          height: 100,
                          radius: 40,
                          image: state.company.image,
                        ),
                        _spacerHeight(),
                        Text(
                          state.company.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        state.company.description != null && state.company.description != ""
                            ? DetailsCard(
                          child: ExpandableText(
                            state.company.description!,
                          ),
                        ) : const SizedBox.shrink(),
                        _spacerHeight(),
                        CustomPieChart(
                          profit: state.company.profit!,
                          salary: state.company.salary!,
                          equipment: state.company.equipment!,
                          service: state.company.service!,
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: CompanyCardInfo(
                                title: "Profit",
                                value: state.company.profit!,
                                percent: _percent(value: state.company.profit!, total: state.company.sales!),
                                color: AppColors.profitColor,
                              ),
                            ),
                            _spacerWidth(),
                            Flexible(
                              flex: 1,
                              child: CompanyCardInfo(
                                title: "Salary",
                                value:  state.company.salary!,
                                percent: _percent(value: state.company.salary!, total: state.company.sales!),
                                color: AppColors.salaryColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: CompanyCardInfo(
                                title: "Equipment",
                                value: state.company.equipment!,
                                percent: _percent(value: state.company.equipment!, total: state.company.sales!),
                                color: AppColors.equipmentColor,
                              ),
                            ),
                            _spacerWidth(),
                            Flexible(
                              flex: 1,
                              child: CompanyCardInfo(
                                title: "Third-party service",
                                value: state.company.service!,
                                percent: _percent(value: state.company.service!, total: state.company.sales!),
                                color: AppColors.serviceColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ) : SkeletonBox(),
                    _spacerHeight(),
                    TitleIconButtomRow(
                      title: 'Group',
                      icon: Icons.add,
                      onPressed: (){
                        showCustomBottomSheet(
                          context: context,
                          minHeight: 0.95,
                          color: null,
                          child: AddGroup(
                            idCompany: widget.company.id!,
                          ),
                        );
                      },
                    ),
                    _spacerHeight(),
                    state is DetailLoading
                    ? SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        itemCount: 10, // Skeleton : 10 items
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return const GroupCardSkeleton();
                        },
                      ),
                    )
                    : state is DetailLoaded
                      ? state.company.groups!.isNotEmpty ? SizedBox(
                        height: 170, // hauteur fixe
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 16),
                          itemCount: state.company.groups!.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12), // espace entre les items
                          itemBuilder: (context, index) {
                            return GroupCard(
                              group: state.company.groups![index],
                              onTap: (){}
                            );
                          },
                        ),
                      ) : const Text("You haven't opened any teams.")
                    : SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        itemCount: 10, // Skeleton : 10 items
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return const GroupCardSkeleton();
                        },
                      ),
                    ),
                    _spacerHeight(),
                    TitleIconButtomRow(
                      title: 'Project',
                      icon: Icons.add,
                      onPressed: (){
                        showCustomBottomSheet(
                          context: context,
                          minHeight: 0.95,
                          color: null,
                          child: AddProject(
                            idCompany: widget.company.id!,
                          ),
                        );
                      },
                    ),
                    _spacerHeight(),
                    state is DetailLoading
                        ? const SizedBox()
                        : state is DetailLoaded && state.company.projects != null && state.company.projects!.isNotEmpty
                        ? Column(
                      children: state.company.projects!.map((projectData) {
                        return ProjectCard(project: projectData,);
                      }).toList(),
                    ) : Column(
                      children: [
                        const Text("No projects have been launched."),
                        _spacerHeight(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  double _percent({required double value, required double total}){
    return value != 0
        ? double.parse(((value * 100)/total).toStringAsFixed(1))
        : 0.0;
  }
}
