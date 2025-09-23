import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/number_format_utils.dart';
import '../../domain/entities/company_model.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';
import 'company_profil.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: (){
            context.push('/companyDetail', extra: company);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                // Avatar
                CompanyProfil(
                  width: 60,
                  height: 60,
                  image: company.image,
                ),
                const SizedBox(width: 12),

                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        company.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      company.description != null && company.description != ""
                        ? const SizedBox(height: 4) : const SizedBox.shrink(),
                      company.description != null && company.description != ""
                        ? Text(
                        company.description!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize!
                        ),
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Date
                Text(
                  NumberFormatUtils.formatCurrency(company.profit as num),
                  style: TextStyle(
                    color: company.profit! == 0.0
                      ? Theme.of(context).iconTheme.color
                      : company.profit! < 0
                        ? Colors.red
                        : Colors.green,
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
