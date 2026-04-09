import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_item_list.dart';
import 'package:flutter/material.dart';

class SubscriptionScreenContent extends StatelessWidget {
  const SubscriptionScreenContent({
    super.key,
    required this.data,
    required this.onTap,
  });
  final MainEntity data;
  final ValueChanged<SubscriptionListItem> onTap;
  @override
  Widget build(BuildContext context) {
    final items = buildSubscriptionListItems(data);
    final activeCount = items.where((item) => item.isActive).length;
    final now = DateTime.now();
    final upcomingCount = items.where((item) {
      final next = item.nextBilling;
      return item.isActive &&
          next != null &&
          !next.isBefore(now) &&
          next.difference(now).inDays <= 7;
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingExtraLarge,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        BicountReveal(
          delay: const Duration(milliseconds: 40),
          child: Text(
            context.l10n.subscriptionIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppDimens.spacingMedium),
        BicountReveal(
          delay: const Duration(milliseconds: 90),
          child: Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              _OverviewCard(
                label: context.l10n.graphActive,
                value: '$activeCount',
                color: Theme.of(context).primaryColor,
              ),
              _OverviewCard(
                label: context.l10n.graphMonthlyLoad,
                value: NumberFormatUtils.compactCurrency(
                  0.0,
                  currencyCode: data.referenceCurrencyCode,
                ),
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.personnalIncome!,
              ),
              _OverviewCard(
                label: context.l10n.graphUpcomingCharges,
                value: '$upcomingCount',
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.companyIncome!,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        SubscriptionItemList(items: items, onTap: onTap),
      ],
    );
  }
}

class SubscriptionLoadingView extends StatelessWidget {
  const SubscriptionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      physics: const BouncingScrollPhysics(),
      children: [
        const BicountSkeletonBox(height: 56),
        const SizedBox(height: AppDimens.spacingMedium),
        Wrap(
          spacing: AppDimens.spacingMedium,
          runSpacing: AppDimens.spacingMedium,
          children: List.generate(
            3,
            (_) => const SizedBox(
              width: 150,
              child: BicountSkeletonBox(height: 92),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        ...List.generate(
          4,
          (_) => const BicountSkeletonBox(
            height: 116,
            margin: EdgeInsets.only(bottom: AppDimens.spacingMedium),
            radius: AppDimens.borderRadiusLarge,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppDimens.spacingSmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
