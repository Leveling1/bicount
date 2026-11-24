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
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 🟣 Avatar placeholder
            SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AppDimens.spacerMediumSmall,

            // 🟢 Name + Date placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 14,
                      width: 120,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 12,
                      width: 60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // 🟠 Amount + Type placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 14,
                    width: 50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AppDimens.spacerSmall,
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 12,
                    width: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
