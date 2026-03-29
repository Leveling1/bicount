import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class FriendsDirectorySkeleton extends StatelessWidget {
  const FriendsDirectorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BicountSkeletonBox(
              height: 120,
              radius: AppDimens.borderRadiusLarge,
            ),
            AppDimens.spacerLarge,
            const BicountSkeletonBox(height: 14, width: 220),
            AppDimens.spacerLarge,
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (_, __) => AppDimens.spacerSmall,
                itemBuilder: (_, __) => const BicountSkeletonBox(
                  height: 74,
                  radius: AppDimens.borderRadiusLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
