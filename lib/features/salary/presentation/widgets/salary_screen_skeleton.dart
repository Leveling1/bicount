import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class SalaryScreenSkeleton extends StatelessWidget {
  const SalaryScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SalaryMetricSkeletonGrid(),
          SizedBox(height: AppDimens.spacingLarge),
          BicountSkeletonBox(height: AppSizes.dp18, width: AppSizes.dp180),
          SizedBox(height: AppDimens.spacingSmall),
          _SalaryOccurrenceSkeletonCard(),
          _SalaryOccurrenceSkeletonCard(),
          SizedBox(height: AppDimens.spacingLarge),
          BicountSkeletonBox(height: AppSizes.dp18, width: AppSizes.dp140),
          SizedBox(height: AppDimens.spacingSmall),
          _SalaryPlanSkeletonCard(),
          _SalaryPlanSkeletonCard(),
          _SalaryPlanSkeletonCard(),
          SizedBox(height: AppDimens.spacingLarge),
          BicountSkeletonBox(height: AppSizes.dp18, width: AppSizes.dp190),
          SizedBox(height: AppDimens.spacingSmall),
          _SalaryOccurrenceSkeletonCard(),
          _SalaryOccurrenceSkeletonCard(),
        ],
      ),
    );
  }
}

class _SalaryMetricSkeletonGrid extends StatelessWidget {
  const _SalaryMetricSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 48) / 2;

    return Wrap(
      spacing: AppDimens.spacingMedium,
      runSpacing: AppDimens.spacingMedium,
      children: List.generate(
        3,
        (_) => _SalaryMetricSkeletonCard(width: cardWidth),
      ),
    );
  }
}

class _SalaryMetricSkeletonCard extends StatelessWidget {
  const _SalaryMetricSkeletonCard({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp90),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: AppSizes.dp24, width: AppSizes.dp100),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp80),
        ],
      ),
    );
  }
}

class _SalaryOccurrenceSkeletonCard extends StatelessWidget {
  const _SalaryOccurrenceSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BicountSkeletonBox(
                  height: AppSizes.dp18,
                  width: AppSizes.dp160,
                ),
              ),
              SizedBox(width: AppDimens.spacingSmall),
              BicountSkeletonBox(
                height: AppSizes.dp26,
                width: AppSizes.dp78,
                radius: AppSizes.dp999,
              ),
            ],
          ),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp140),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp132),
          SizedBox(height: AppDimens.spacingMedium),
          BicountSkeletonBox(height: AppSizes.dp16, width: AppSizes.dp110),
        ],
      ),
    );
  }
}

class _SalaryPlanSkeletonCard extends StatelessWidget {
  const _SalaryPlanSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BicountSkeletonBox(
                  height: AppSizes.dp18,
                  width: AppSizes.dp170,
                ),
              ),
              SizedBox(width: AppDimens.spacingSmall),
              BicountSkeletonBox(
                height: AppSizes.dp26,
                width: AppSizes.dp92,
                radius: AppSizes.dp999,
              ),
            ],
          ),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: AppSizes.dp16, width: AppSizes.dp118),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp160),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: AppSizes.dp12, width: AppSizes.dp190),
        ],
      ),
    );
  }
}
