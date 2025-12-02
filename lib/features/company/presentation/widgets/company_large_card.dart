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
                      constraints: const BoxConstraints(minWidth: 70),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusFull,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                CompanyProfil(
                  width: 120,
                  height: 120,
                  radius: 50,
                  image: company.image,
                ),
                const SizedBox(height: 12),
                Text(
                  company.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                company.description != null && company.description != ""
                    ? const SizedBox(height: 4)
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
                const SizedBox(height: 12),
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
                          const SizedBox(height: 4),
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
                          const SizedBox(height: 4),
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
                            "Total",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
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
