import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnalysisMetricCard extends StatelessWidget {
  const AnalysisMetricCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.currencyCode,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final double width;
  final String title;
  final double value;
  final String currencyCode;
  final Color color;
  final String icon;
  final VoidCallback? onTap;
  static const _compactThreshold = 10000;

  @override
  Widget build(BuildContext context) {
    final content = DetailsCard(
      isMargin: false,
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
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return Text(
                NumberFormatUtils.compactCurrency(
                  animatedValue,
                  currencyCode: currencyCode,
                  compactThreshold: _compactThreshold,
                  thousandSuffix: 'k',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );

    return SizedBox(
      width: width,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
              child: content,
            ),
    );
  }
}
