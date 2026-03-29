import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class DetailFriendSkeleton extends StatelessWidget {
  const DetailFriendSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingMedium,
        ),
        children: const [
          BicountSkeletonBox(height: 170, radius: AppDimens.borderRadiusLarge),
          AppDimens.spacerLarge,
          BicountSkeletonBox(height: 80, radius: AppDimens.borderRadiusLarge),
          AppDimens.spacerLarge,
          BicountSkeletonBox(height: 110, radius: AppDimens.borderRadiusLarge),
          AppDimens.spacerLarge,
          BicountSkeletonBox(height: 240, radius: AppDimens.borderRadiusLarge),
        ],
      ),
    );
  }
}
