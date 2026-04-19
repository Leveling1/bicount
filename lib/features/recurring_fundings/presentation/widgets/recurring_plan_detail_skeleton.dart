import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class RecurringPlanDetailSkeleton extends StatelessWidget {
  const RecurringPlanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                BicountSkeletonCircle(size: 32),
                SizedBox(width: AppDimens.spacingSmall),
                BicountSkeletonCircle(size: 32),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          const BicountSkeletonBox(height: 30, width: 220),
          const SizedBox(height: AppDimens.spacingSmall),
          const BicountSkeletonBox(height: 26, width: 90, radius: 999),
          const SizedBox(height: AppDimens.spacingMedium),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BicountSkeletonBox(height: 24, width: 130),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(height: 14, width: 120),
                SizedBox(height: AppDimens.spacingSmall),
                Wrap(
                  spacing: AppDimens.spacingSmall,
                  runSpacing: AppDimens.spacingSmall,
                  children: [
                    BicountSkeletonBox(height: 34, width: 140, radius: 999),
                    BicountSkeletonBox(height: 34, width: 150, radius: 999),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BicountSkeletonBox(height: 14, width: 190),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(height: 14, width: 210),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(height: 14, width: 150),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          const BicountSkeletonBox(
            height: 48,
            radius: AppDimens.borderRadiusUltraLarge,
          ),
          AppDimens.spacerMedium,
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: child,
    );
  }
}
