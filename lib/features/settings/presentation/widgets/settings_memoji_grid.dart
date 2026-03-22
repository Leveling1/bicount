import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:bicount/features/settings/domain/entities/settings_memoji_entity.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_avatar.dart';
import 'package:flutter/material.dart';

class SettingsMemojiGrid extends StatelessWidget {
  const SettingsMemojiGrid({
    super.key,
    required this.controller,
    required this.items,
    required this.selectedImage,
    required this.isLoadingMore,
    required this.onSelected,
  });

  final ScrollController controller;
  final List<SettingsMemojiEntity> items;
  final String selectedImage;
  final bool isLoadingMore;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final totalItems = items.length + (isLoadingMore ? 4 : 0);
    return SizedBox(
      height: AppDimens.settingsAvatarPickerHeight,
      child: GridView.builder(
        controller: controller,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: AppDimens.spacingMedium,
          crossAxisSpacing: AppDimens.spacingMedium,
          childAspectRatio: 0.92,
        ),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(
              child: BicountSkeletonCircle(size: AppDimens.settingsAvatarTileSize),
            );
          }

          final item = items[index];
          final selected = item.url == selectedImage;
          return GestureDetector(
            onTap: () => onSelected(item.url),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: selected ? 1.04 : 1,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.paddingExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusFull,
                  ),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: SettingsAvatar(
                  image: item.url,
                  radius: AppDimens.settingsAvatarTileRadius,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
