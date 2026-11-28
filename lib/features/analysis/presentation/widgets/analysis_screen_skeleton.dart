import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class AnalysisScreenSkeleton extends StatelessWidget {
  const AnalysisScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingLarge,
        AppDimens.paddingMedium,
        AppSizes.dp120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BicountSkeletonBox(height: AppSizes.dp22, width: AppSizes.dp160),
          AppDimens.spacerSmall,
          BicountSkeletonBox(height: AppSizes.dp14, width: AppSizes.dp240),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp44,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          _AnalysisMetricSkeleton(),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp240,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp220,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp200,
            radius: AppDimens.borderRadiusLarge,
          ),
        ],
      ),
    );
  }
}

class _AnalysisMetricSkeleton extends StatelessWidget {
  const _AnalysisMetricSkeleton();

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
        BicountSkeletonBox(
          height: AppSizes.dp100,
          radius: AppDimens.borderRadiusLarge,
        ),
        BicountSkeletonBox(
          height: AppSizes.dp100,
          radius: AppDimens.borderRadiusLarge,
        ),
        BicountSkeletonBox(
          height: AppSizes.dp100,
          radius: AppDimens.borderRadiusLarge,
        ),
        BicountSkeletonBox(
          height: AppSizes.dp100,
          radius: AppDimens.borderRadiusLarge,
        ),
      ],
    );
  }
}
