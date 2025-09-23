import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/expandable_text.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../core/widgets/details_card.dart';
import '../../domain/entities/group_model.dart';
import '../../domain/entities/company_model.dart';
import '../widgets/company_card_info.dart';
import '../widgets/company_profil.dart';
import '../widgets/custom_pie_chart.dart';
import '../widgets/group_card.dart';
import '../widgets/title_icon_buttom_row.dart';
import 'add_group.dart';

class DetailCompanyScreen extends StatefulWidget {
  final CompanyModel company;
  const DetailCompanyScreen({super.key, required this.company});

  @override
  State<DetailCompanyScreen> createState() => _DetailCompanyScreenState();
}

class _DetailCompanyScreenState extends State<DetailCompanyScreen> {
  Widget _spacerHeight() => const SizedBox(height: AppDimens.marginMedium);
  Widget _spacerWidth() => const SizedBox(width: AppDimens.marginMedium);

  final List<GroupModel> ephemeralCompanyGroups = [
    GroupModel(
      id: 1,
      idCompany: 101,
      name: "Tech Innovators",
      description: "Groupe dédié aux startups tech innovantes.",
      image: "https://example.com/images/tech_innovators.png",
      number: 25,
      createdAt: DateTime.now(),
    ),
    GroupModel(
      id: 2,
      idCompany: 102,
      name: "Green Energy Alliance",
      description: "Promotion des solutions énergétiques durables.",
      image: null, // pas d'image
      number: 40,
      createdAt: DateTime.now(),
    ),
    GroupModel(
      id: 3,
      idCompany: 103,
      name: "Marketing Gurus",
      description: null, // pas de description
      image: "https://example.com/images/marketing_gurus.png",
      number: 10, // nombre non défini
      createdAt: DateTime.now(),
    ),
    GroupModel(
      id: 4,
      idCompany: 104,
      name: "AI Research Lab",
      description: "Laboratoire de recherche en intelligence artificielle.",
      image: "https://example.com/images/ai_lab.png",
      number: 12,
      createdAt: DateTime.now(),
    ),
    GroupModel(
      id: 5,
      idCompany: 105,
      name: "E-commerce Pioneers",
      description: "Experts dans le commerce en ligne et le retail digital.",
      image: null,
      number: 30,
      createdAt: DateTime.now(),
    ),
  ];


  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.of(context).pop(),
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
                CompanyProfil(
                  width: 100,
                  height: 100,
                  radius: 50,
                  image: widget.company.image,
                ),
                _spacerHeight(),
                Text(
                  widget.company.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                widget.company.description != null && widget.company.description != ""
                ? DetailsCard(
                  child: ExpandableText(
                    widget.company.description!,
                  ),
                ) : const SizedBox.shrink(),
                _spacerHeight(),
                CustomPieChart(
                  profit: widget.company.profit!,
                  salary: widget.company.salary!,
                  equipment: widget.company.equipment!,
                  service: widget.company.service!,
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Profit",
                        value: widget.company.profit!,
                        percent: 0,
                        color: AppColors.profitColor,
                      ),
                    ),
                    _spacerWidth(),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Salary",
                        value:  widget.company.salary!,
                        percent: 0,
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
                        value: widget.company.equipment!,
                        percent: 0,
                        color: AppColors.equipmentColor,
                      ),
                    ),
                    _spacerWidth(),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Third-party service",
                        value: widget.company.service!,
                        percent: 0,
                        color: AppColors.serviceColor,
                      ),
                    ),
                  ],
                ),
                _spacerHeight(),
                TitleIconButtomRow(
                  title: 'Group',
                  icon: Icons.add,
                  onPressed: (){
                    showCustomBottomSheet(
                      context: context,
                      minHeight: 0.95,
                      color: null,
                      child: AddCompanyGroup(
                        idCompany: widget.company.id!,
                      ),
                    );
                  },
                ),
                _spacerHeight(),
                SizedBox(
                  height: 170, // hauteur fixe
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal, // 👈 défilement horizontal
                    padding: const EdgeInsets.only(right: 16),
                    itemCount: ephemeralCompanyGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12), // espace entre les items
                    itemBuilder: (context, index) {
                      return GroupCard(
                        group: ephemeralCompanyGroups[index],
                        onTap: (){}
                      );
                    },
                  ),
                ),
                _spacerHeight(),
                TitleIconButtomRow(
                  title: 'Project',
                  icon: Icons.add,
                  onPressed: (){},
                ),
                _spacerHeight(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
