import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/number_format_utils.dart';
import '../../data/models/company.model.dart';
import 'company_profil.dart';

class CompanyLargeCard extends StatelessWidget {
  final CompanyModel company;
  final String role;
  const CompanyLargeCard({
    super.key,
    required this.company,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final profit = company.profit!;
    final colorProfit = profit < 0 ? Colors.red : Colors.green;

    final expenses = company.expenses!;
    final colorExpense = expenses == 0
        ? Theme.of(context).textTheme.bodyLarge!.color
        : Colors.red;

    final revenue = profit + expenses;
    final colorRevenue = Theme.of(context).textTheme.bodyLarge!.color;
    final Color badgeColor = role == "owner"
        ? Theme.of(context).primaryColor
        : Colors.blueAccent;

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
            padding: AppDimens.paddingVerticalLargeHorizontalExtraLarge,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: AppSizes.dp70,
                      ),
                      decoration: ShapeDecoration(
                        color: badgeColor.withValues(alpha: 0.3),
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadiusFull,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingSmall,
                        vertical: AppDimens.paddingExtraSmall,
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: AppSizes.dp11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                CompanyProfil(
                  width: AppSizes.dp120,
                  height: AppSizes.dp120,
                  radius: AppSizes.dp50,
                  image: company.image,
                ),
                const SizedBox(height: AppSizes.dp12),
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
                const SizedBox(height: AppSizes.dp12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            "Profit",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppDimens.spacingExtraSmall),
                          Text(
                            NumberFormatUtils.formatCurrency(profit),
                            style: TextStyle(
                              color: colorProfit,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            "Expenses",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppDimens.spacingExtraSmall),
                          Text(
                            NumberFormatUtils.formatCurrency(expenses),
                            style: TextStyle(
                              color: colorExpense,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            "Net Revenue",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppDimens.spacingExtraSmall),
                          Text(
                            NumberFormatUtils.formatCurrency(revenue),
                            style: TextStyle(
                              color: colorRevenue,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
