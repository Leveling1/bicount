import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180.w,
        decoration: BoxDecoration(
          gradient: AppColors.cardLinearGradientLight,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          border: Border.all(color: Colors.grey),
        ),

        padding: AppDimens.paddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimens.spacingMedium,
          children: [
            Container(
              padding: AppDimens.paddingAllSmall,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: icon,
            ),
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
    );
  }
}
