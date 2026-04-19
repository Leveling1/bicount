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
          BicountSkeletonBox(height: 18, width: 180),
          SizedBox(height: AppDimens.spacingSmall),
          _SalaryOccurrenceSkeletonCard(),
          _SalaryOccurrenceSkeletonCard(),
          SizedBox(height: AppDimens.spacingLarge),
          BicountSkeletonBox(height: 18, width: 140),
          SizedBox(height: AppDimens.spacingSmall),
          _SalaryPlanSkeletonCard(),
          _SalaryPlanSkeletonCard(),
          _SalaryPlanSkeletonCard(),
          SizedBox(height: AppDimens.spacingLarge),
          BicountSkeletonBox(height: 18, width: 190),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BicountSkeletonBox(height: 12, width: 90),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: 24, width: 100),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: 12, width: 80),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BicountSkeletonBox(height: 18, width: 160)),
              SizedBox(width: AppDimens.spacingSmall),
              BicountSkeletonBox(height: 26, width: 78, radius: 999),
            ],
          ),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: 12, width: 140),
          SizedBox(height: AppDimens.spacingExtraSmall),
          BicountSkeletonBox(height: 12, width: 132),
          SizedBox(height: AppDimens.spacingMedium),
          BicountSkeletonBox(height: 16, width: 110),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BicountSkeletonBox(height: 18, width: 170)),
              SizedBox(width: AppDimens.spacingSmall),
              BicountSkeletonBox(height: 26, width: 92, radius: 999),
            ],
          ),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: 16, width: 118),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: 12, width: 160),
          SizedBox(height: AppDimens.spacingSmall),
          BicountSkeletonBox(height: 12, width: 190),
        ],
      ),
    );
  }
}
