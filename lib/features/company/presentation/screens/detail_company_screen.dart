import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/expandable_text.dart';
import '../../../../core/widgets/details_card.dart';
import '../../domain/entities/company_model.dart';
import '../widgets/company_card_info.dart';
import '../widgets/company_profil.dart';
import '../widgets/custom_pie_chart.dart';

class DetailCompanyScreen extends StatefulWidget {
  final CompanyModel company;
  const DetailCompanyScreen({super.key, required this.company});

  @override
  State<DetailCompanyScreen> createState() => _DetailCompanyScreenState();
}

class _DetailCompanyScreenState extends State<DetailCompanyScreen> {
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
                const SizedBox(height: AppDimens.marginMedium),
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
                const SizedBox(height: AppDimens.marginMedium),
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
                        value: 0,
                        percent: 0,
                        color: AppColors.profitColor,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Salary",
                        value: 0,
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
                        value: 0,
                        percent: 0,
                        color: AppColors.equipmentColor,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Third-party service",
                        value: 0,
                        percent: 0,
                        color: AppColors.serviceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.marginMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
