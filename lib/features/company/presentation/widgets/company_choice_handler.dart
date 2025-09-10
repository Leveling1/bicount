import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_dimens.dart';

class CompanyChoiceHandler extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const CompanyChoiceHandler({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: AppDimens.paddingAllMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left part with icon and text
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: AppDimens.paddingAllMedium,
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                SizedBox(width: AppDimens.marginLarge),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                ),
                // Right arrow icon
                Icon(Icons.arrow_forward_ios, size: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
