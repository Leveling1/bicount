import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class SettingsMemojiLoadingGrid extends StatelessWidget {
  const SettingsMemojiLoadingGrid({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.settingsAvatarPickerHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: AppDimens.spacingMedium,
          crossAxisSpacing: AppDimens.spacingMedium,
          childAspectRatio: 0.92,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) {
          return const Center(
            child: BicountSkeletonCircle(
              size: AppDimens.settingsAvatarTileSize,
            ),
          );
        },
      ),
    );
  }
}
