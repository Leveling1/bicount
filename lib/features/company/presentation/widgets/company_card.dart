import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/number_format_utils.dart';
import '../../data/models/company.model.dart';
import 'company_profil.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.dp20),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          customBorder: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          ),
          onTap: () {
            context.push('/companyDetail', extra: company.cid);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.paddingSmallMedium,
              horizontal: AppDimens.paddingSmallMedium,
            ),
            child: Row(
              children: [
                // Avatar
                CompanyProfil(
                  width: AppSizes.dp60,
                  height: AppSizes.dp60,
                  image: company.image,
                ),
                const SizedBox(width: AppSizes.dp12),

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
                          ? const SizedBox(height: AppDimens.spacingExtraSmall)
                          : const SizedBox.shrink(),
                      company.description != null && company.description != ""
                          ? Text(
                              company.description!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.fontSize!,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.dp12),
                // Date
                Text(
                  NumberFormatUtils.formatCurrency(company.profit!),
                  style: TextStyle(
                    color: company.profit! == 0.0
                        ? Theme.of(context).iconTheme.color
                        : company.profit! < 0
                        ? Colors.red
                        : Colors.green,
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.bold,
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
