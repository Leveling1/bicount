import 'corner_skeleton_box.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingSmallMedium,
          horizontal: AppDimens.paddingMedium,
        ),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          ),
        ),
        child: Row(
          children: [
            // 🟣 Avatar placeholder
            CornerSkeletonBox(
              width: AppSizes.dp40,
              height: AppSizes.dp40,
              radius: AppSizes.dp20,
            ),
            AppDimens.spacerMediumSmall,

            // 🟢 Name + Date placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CornerSkeletonBox(
                    height: AppSizes.dp14,
                    width: AppSizes.dp120,
                    radius: AppSizes.dp4,
                  ),
                  const SizedBox(height: AppDimens.spacingSmall),
                  CornerSkeletonBox(
                    height: AppSizes.dp12,
                    width: AppSizes.dp60,
                    radius: AppSizes.dp4,
                  ),
                ],
              ),
            ),

            // 🟠 Amount + Type placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CornerSkeletonBox(
                  height: AppSizes.dp14,
                  width: AppSizes.dp50,
                  radius: AppSizes.dp4,
                ),
                AppDimens.spacerSmall,
                CornerSkeletonBox(
                  height: AppSizes.dp12,
                  width: AppSizes.dp40,
                  radius: AppSizes.dp4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
