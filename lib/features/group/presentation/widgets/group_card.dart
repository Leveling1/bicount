import 'package:bicount/features/group/data/models/group.model.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  const GroupCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const width = AppSizes.dp120;
    const height = AppSizes.dp120;
    const radius = AppSizes.dp50;
    return SizedBox(
      width: AppSizes.dp120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          customBorder: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          ),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 5, bottom: 5),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).bottomNavigationBarTheme.backgroundColor,
                  radius: radius,
                  child: ClipOval(
                    child: group.image != null && group.image != ""
                        ? CachedNetworkImage(
                            imageUrl: group.image!,
                            width: width,
                            height: height,
                            placeholder: (context, url) => CircleImageSkeleton(
                              width: width,
                              height: height,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(
                              AppDimens.paddingSmall,
                            ),
                            child: Icon(
                              Icons.people,
                              size: width,
                              color: AppColors.inactiveColorDark,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSizes.dp5),
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${group.number} members',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
