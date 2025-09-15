import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/expandable_text.dart';
import '../../../../core/widgets/details_card.dart';
import '../../domain/entities/company_model.dart';
import '../widgets/company_card_info.dart';
import '../widgets/company_profil.dart';

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
                DetailsCard(
                  child: ExpandableText(
                    widget.company.description!,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Sales",
                        value: 0,
                        percent: 0,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Profit",
                        value: 0,
                        percent: 0,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Sales",
                        value: 0,
                        percent: 0,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: CompanyCardInfo(
                        title: "Profit",
                        value: 0,
                        percent: 0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
