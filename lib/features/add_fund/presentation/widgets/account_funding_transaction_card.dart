import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:flutter/material.dart';

class AccountFundingTransactionCard extends StatelessWidget {
  const AccountFundingTransactionCard({
    super.key,
    required this.funding,
    this.onTap,
  });

  final AccountFundingModel funding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timelineDate =
        DateTime.tryParse(funding.createdAt ?? '') ??
        DateTime.tryParse(funding.date) ??
        DateTime.now();
    final amount = NumberFormatUtils.formatCurrency(
      funding.amount,
      currencyCode: funding.currency,
    );

    return Material(
      color: Colors.transparent,
      child: BicountPressable(
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,
        customBorder: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
        onTap: onTap,
        child: Padding(
          padding: AppDimens.paddingSmallCard,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                radius: AppSizes.dp20,
                child: SizedBox(
                  width: AppSizes.dp30,
                  height: AppSizes.dp30,
                  child: Icon(
                    Icons.savings_outlined,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              AppDimens.spacerWidthMediumSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      funding.source,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      TimeOfDay.fromDateTime(timelineDate).format(context),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: AppSizes.dp13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+ $amount',
                    style: const TextStyle(
                      color: AppColors.primaryColorDark,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.dp16,
                    ),
                  ),
                  Text(
                    context.l10n.transactionTypeAddFund,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
