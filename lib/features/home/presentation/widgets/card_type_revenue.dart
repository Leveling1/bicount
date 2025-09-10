import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_gradient.dart';

class CardTypeRevenue extends StatelessWidget {
  const CardTypeRevenue({
    super.key,
    required this.label,
    required this.icon,
    required this.amount,
    this.color = Colors.amber,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final Color color;
  final double amount;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155.w,
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: AppDimens.paddingAllExtraLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppDimens.paddingAllSmall,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: icon,
                ),
                SizedBox(height: 4.5.h),
                Text(
                  NumberFormatUtils.formatCurrency(amount),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
