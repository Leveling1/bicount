import 'package:bicount/features/project/domain/entities/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              radius: 30,
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: project.image != null && project.image != ""
                    ? CachedNetworkImage(
                  imageUrl: project.image!,
                  width: 40.w,
                  height: 40.h,
                  placeholder: (context, url) => CircleImageSkeleton(
                      width: 40.w,
                      height: 40.h
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ) : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.people,
                    size: 30,
                    color: AppColors.inactiveColorDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Initiated by ${project.initiator}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Amount
            /*Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign ${transaction.amount}',
                  style: TextStyle(
                    color: sign == "+"
                        ? AppColors.primaryColorDark
                        : AppColors.negativeColorDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  transaction.type.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
