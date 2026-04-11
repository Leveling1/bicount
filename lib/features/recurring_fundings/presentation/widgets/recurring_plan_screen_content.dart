import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_collection_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_card.dart';
import 'package:flutter/material.dart';

class RecurringPlanScreenContent extends StatelessWidget {
  const RecurringPlanScreenContent({
    super.key,
    required this.scope,
    required this.data,
    required this.referenceCurrencyCode,
    required this.collection,
    required this.onTap,
  });

  final RecurringPlanScope scope;
  final MainEntity data;
  final String referenceCurrencyCode;
  final RecurringPlanCollectionEntity collection;
  final ValueChanged<RecurringPlanSummaryEntity> onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = scope == RecurringPlanScope.charge
        ? Theme.of(context).extension<OtherTheme>()!.expense!
        : Theme.of(context).extension<OtherTheme>()!.income!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingExtraLarge,
      ),
      children: [
        BicountReveal(
          delay: const Duration(milliseconds: 40),
          child: Text(
            scope == RecurringPlanScope.charge
                ? context.l10n.recurringChargesIntro
                : context.l10n.recurringIncomesIntro,
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
                value: '${collection.activeCount}',
                color: Theme.of(context).primaryColor,
              ),
              _OverviewCard(
                label: context.l10n.graphMonthlyLoad,
                value: NumberFormatUtils.compactCurrency(
                  collection.monthlyReferenceAmount,
                  currencyCode: referenceCurrencyCode,
                ),
                color: accentColor,
              ),
              _OverviewCard(
                label: context.l10n.graphUpcomingCharges,
                value: '${collection.upcomingCount}',
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.companyIncome!,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        if (!collection.hasPlans)
          _EmptyState(
            message: scope == RecurringPlanScope.charge
                ? context.l10n.recurringChargesEmpty
                : context.l10n.recurringIncomesEmpty,
          )
        else
          ...List.generate(collection.plans.length, (index) {
            final summary = collection.plans[index];
            return BicountReveal(
              delay: Duration(milliseconds: 130 + (index * 40)),
              child: RecurringPlanCard(
                scope: scope,
                summary: summary,
                referenceCurrencyCode: referenceCurrencyCode,
                onTap: () => onTap(summary),
              ),
            );
          }),
      ],
    );
  }
}

class RecurringPlanLoadingView extends StatelessWidget {
  const RecurringPlanLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Icons.autorenew_rounded,
            size: AppDimens.iconSizeLarge,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
