import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/features/project/data/models/project.model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../../../core/utils/number_format_utils.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    String endDate = project.endDate != null
        ? formatDateSmall(DateTime.parse(project.endDate!))
        : "now";
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: appPressShape,
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,

        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingSmallMedium,
          ),
          decoration: BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                radius: AppSizes.dp30,
                child: ClipOval(
                  child: project.image != null && project.image != ""
                      ? CachedNetworkImage(
                          imageUrl: project.image!,
                          width: AppSizes.dp60,
                          height: AppSizes.dp60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircleImageSkeleton(
                            width: AppSizes.dp60,
                            height: AppSizes.dp60,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppDimens.paddingSmall),
                          child: Icon(
                            Icons.lightbulb,
                            size: AppSizes.dp30,
                            color: AppColors.inactiveColorDark,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSizes.dp12),

              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimens.spacingExtraSmall),
                    Text(
                      "Initiated by ${project.initiator}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: AppSizes.dp13,
                      ),
                    ),
                  ],
                ),
              ),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatDateSmall(DateTime.parse(project.startDate))} - $endDate',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    NumberFormatUtils.formatCurrency(project.profit as num),
                    style: TextStyle(
                      color: project.profit == 0.0
                          ? Theme.of(context).textTheme.bodySmall!.color
                          : project.profit! > 0.0
                          ? AppColors.primaryColorDark
                          : AppColors.negativeColorDark,
                      fontSize: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
