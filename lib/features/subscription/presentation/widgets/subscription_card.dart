import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_badge.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formated_text.dart';
import 'meta_pill.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.item, required this.onTap});
  final SubscriptionListItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final statusColor = SubscriptionConst.getStatusColor(
      item.subscription.status ?? SubscriptionConst.active,
      context,
    );
    final accentColor =
        Theme.of(context).extension<OtherTheme>()!.companyIncome ??
        Theme.of(context).primaryColor;
    final amount = NumberFormatUtils.formatCurrency(
      item.subscription.amount,
      currencyCode: item.subscription.currency,
    );
    final monthlyLoad = NumberFormatUtils.compactCurrency(
      item.monthlyAmount,
      currencyCode: item.subscription.currency,
    );
    final scheduleDate = item.isActive ? item.nextBilling : item.endDate;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        FormatedText().capitalizeFirstLetter(
                          item.subscription.title,
                        ),
                        maxLines: AppDimens.maxLinesShort,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppDimens.spacingSmall),
                    SubscriptionBadge(
                      label: context.subscriptionStatusLabel(
                        item.subscription.status ?? SubscriptionConst.active,
                      ),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingExtraSmall),
                Text(
                  context.frequencyLabel(item.subscription.frequency),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimens.spacingSmall),
                Wrap(
                  spacing: AppDimens.spacingSmall,
                  runSpacing: AppDimens.spacingSmall,
                  children: [
                    MetaPill(
                      icon: Icons.event_outlined,
                      label: item.isActive
                          ? context.l10n.subscriptionNextBilling
                          : context.l10n.subscriptionBillingStop,
                      value: scheduleDate == null
                          ? '-'
                          : formatDateWithoutYear(scheduleDate),
                    ),
                    MetaPill(
                      icon: Icons.insights_outlined,
                      label: context.l10n.graphMonthlyLoad,
                      value: monthlyLoad,
                      color: accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingMedium),
                Text(
                  amount,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
