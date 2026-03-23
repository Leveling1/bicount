import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class GraphSubscriptionInsightCard extends StatelessWidget {
  const GraphSubscriptionInsightCard({super.key, required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: AppDimens.spacingSmall,
            runSpacing: AppDimens.spacingSmall,
            children: [
              GraphSubscriptionStat(
                title: context.l10n.graphActive,
                value: '${dashboard.activeSubscriptionCount}',
              ),
              GraphSubscriptionStat(
                title: context.l10n.graphMonthlyLoad,
                value: NumberFormatUtils.formatCurrency(
                  dashboard.monthlySubscriptionSpend,
                ),
              ),
              GraphSubscriptionStat(
                title: context.l10n.graphNext7Days,
                value: NumberFormatUtils.formatCurrency(
                  dashboard.dueSoonAmount,
                ),
              ),
            ],
          ),
          if (dashboard.upcomingSubscriptions.isNotEmpty) ...[
            AppDimens.spacerLarge,
            Text(
              context.l10n.graphUpcomingCharges,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppDimens.spacerMedium,
            ...dashboard.upcomingSubscriptions.map((subscription) {
              final nextBillingDate = DateFormat(
                'dd MMM yyyy',
              ).format(subscription.nextBillingDate);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.14),
                      child: Icon(
                        Icons.subscriptions_outlined,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    AppDimens.spacerMediumSmall,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          AppDimens.spacerUltraSmall,
                          Text(
                            '${context.frequencyLabel(subscription.frequency)} - $nextBillingDate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormatUtils.formatCurrency(subscription.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            AppDimens.spacerLarge,
            Text(
              context.l10n.graphNoActiveSubscriptions,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class GraphSubscriptionStat extends StatelessWidget {
  const GraphSubscriptionStat({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          AppDimens.spacerMini,
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
