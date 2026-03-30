import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GraphMetricCard extends StatelessWidget {
  const GraphMetricCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.currencyCode,
    required this.color,
    required this.icon,
  });

  final double width;
  final String title;
  final double value;
  final String currencyCode;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DetailsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.14),
              child: SvgPicture.asset(
                icon,
                width: AppDimens.iconSizeSmall,
                height: AppDimens.iconSizeSmall,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: AppDimens.marginMedium),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return Text(
                  NumberFormatUtils.formatCurrency(
                    animatedValue,
                    currencyCode: currencyCode,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
