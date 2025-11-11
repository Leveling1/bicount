import 'package:bicount/features/group/data/models/group.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  const GroupCard({
    super.key,
    required this.group,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final width = 120.0;
    final height = 120.0;
    final radius = 50.0;
    return SizedBox(
      width: 120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 5, bottom: 5),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                  radius: radius,
                  child: ClipOval(
                    child: group.image != null && group.image != ""
                    ? CachedNetworkImage(
                      imageUrl: group.image!,
                      width: width.w,
                      height: height.h,
                      placeholder: (context, url) => CircleImageSkeleton(
                          width: width.w,
                          height: height.h
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ) : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.people,
                        size: width,
                        color: AppColors.inactiveColorDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
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