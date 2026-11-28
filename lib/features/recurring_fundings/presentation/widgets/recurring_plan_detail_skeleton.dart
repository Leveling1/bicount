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
                BicountSkeletonCircle(size: AppSizes.dp32),
                SizedBox(width: AppDimens.spacingSmall),
                BicountSkeletonCircle(size: AppSizes.dp32),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          const BicountSkeletonBox(
            height: AppSizes.dp30,
            width: AppSizes.dp220,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          const BicountSkeletonBox(
            height: AppSizes.dp26,
            width: AppSizes.dp90,
            radius: AppSizes.dp999,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BicountSkeletonBox(
                  height: AppSizes.dp24,
                  width: AppSizes.dp130,
                ),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(
                  height: AppSizes.dp14,
                  width: AppSizes.dp120,
                ),
                SizedBox(height: AppDimens.spacingSmall),
                Wrap(
                  spacing: AppDimens.spacingSmall,
                  runSpacing: AppDimens.spacingSmall,
                  children: [
                    BicountSkeletonBox(
                      height: AppSizes.dp34,
                      width: AppSizes.dp140,
                      radius: AppSizes.dp999,
                    ),
                    BicountSkeletonBox(
                      height: AppSizes.dp34,
                      width: AppSizes.dp150,
                      radius: AppSizes.dp999,
                    ),
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
                BicountSkeletonBox(
                  height: AppSizes.dp14,
                  width: AppSizes.dp190,
                ),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(
                  height: AppSizes.dp14,
                  width: AppSizes.dp210,
                ),
                SizedBox(height: AppDimens.spacingSmall),
                BicountSkeletonBox(
                  height: AppSizes.dp14,
                  width: AppSizes.dp150,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          const BicountSkeletonBox(
            height: AppSizes.dp48,
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
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: child,
    );
  }
}
