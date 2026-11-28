import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/corner_skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class CompanyCardSkeleton extends StatelessWidget {
  const CompanyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingSmallMedium,
          horizontal: AppDimens.paddingSmallMedium,
        ),
        margin: const EdgeInsets.only(bottom: AppSizes.dp20),
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppSizes.dp16),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CornerSkeletonBox(
              width: AppSizes.dp60,
              height: AppSizes.dp60,
              radius: AppSizes.dp50,
            ),
            const SizedBox(width: AppSizes.dp12),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CornerSkeletonBox(
                    height: AppSizes.dp16,
                    width: double.infinity,
                    radius: AppSizes.dp8,
                  ),
                  const SizedBox(height: AppDimens.spacingSmall),
                  CornerSkeletonBox(
                    height: AppSizes.dp12,
                    width: AppSizes.dp150,
                    radius: AppSizes.dp8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.dp12),
            // Profit
            CornerSkeletonBox(
              height: AppSizes.dp16,
              width: AppSizes.dp50,
              radius: AppSizes.dp8,
            ),
          ],
        ),
      ),
    );
  }
}
