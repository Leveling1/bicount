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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CornerSkeletonBox(width: 60, height: 60, radius: 50),
            const SizedBox(width: 12),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CornerSkeletonBox(
                    height: 16,
                    width: double.infinity,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),
                  CornerSkeletonBox(height: 12, width: 150, radius: 8),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Profit
            CornerSkeletonBox(height: 16, width: 50, radius: 8),
          ],
        ),
      ),
    );
  }
}
