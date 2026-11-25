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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // 🟣 Avatar placeholder
            CornerSkeletonBox(width: 40, height: 40, radius: 20),
            AppDimens.spacerMediumSmall,

            // 🟢 Name + Date placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CornerSkeletonBox(height: 14, width: 120, radius: 4),
                  const SizedBox(height: 8),
                  CornerSkeletonBox(height: 12, width: 60, radius: 4),
                ],
              ),
            ),

            // 🟠 Amount + Type placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CornerSkeletonBox(height: 14, width: 50, radius: 4),
                AppDimens.spacerSmall,
                CornerSkeletonBox(height: 12, width: 40, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
