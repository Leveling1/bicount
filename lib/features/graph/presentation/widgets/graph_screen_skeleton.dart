import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class GraphScreenSkeleton extends StatelessWidget {
  const GraphScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingLarge,
        AppDimens.paddingMedium,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BicountSkeletonBox(height: 22, width: 160),
          AppDimens.spacerSmall,
          BicountSkeletonBox(height: 14, width: 240),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: 44,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          _GraphMetricSkeleton(),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: 240,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: 220,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: 200,
            radius: AppDimens.borderRadiusLarge,
          ),
        ],
      ),
    );
  }
}

class _GraphMetricSkeleton extends StatelessWidget {
  const _GraphMetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: AppDimens.spacingMedium,
      mainAxisSpacing: AppDimens.spacingMedium,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: const [
        BicountSkeletonBox(height: 100, radius: AppDimens.borderRadiusLarge),
        BicountSkeletonBox(height: 100, radius: AppDimens.borderRadiusLarge),
        BicountSkeletonBox(height: 100, radius: AppDimens.borderRadiusLarge),
        BicountSkeletonBox(height: 100, radius: AppDimens.borderRadiusLarge),
      ],
    );
  }
}
