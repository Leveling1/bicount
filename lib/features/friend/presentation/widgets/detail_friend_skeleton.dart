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
          BicountSkeletonBox(
            height: AppSizes.dp170,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp80,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp110,
            radius: AppDimens.borderRadiusLarge,
          ),
          AppDimens.spacerLarge,
          BicountSkeletonBox(
            height: AppSizes.dp240,
            radius: AppDimens.borderRadiusLarge,
          ),
        ],
      ),
    );
  }
}
