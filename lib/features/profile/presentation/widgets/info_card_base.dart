import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class InfoCardBase extends StatelessWidget {
  const InfoCardBase({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
    this.linear = false,
  });

  final String icon;
  final String title;
  final Color color;
  final Widget child;
  final bool linear;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: linear
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _InfoCardHeader(
                    icon: icon,
                    title: title,
                    color: color,
                    compact: true,
                  ),
                ),
                const SizedBox(width: AppDimens.marginSmall),
                child,
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _InfoCardHeader(icon: icon, title: title, color: color),
                const SizedBox(height: 20),
                child,
              ],
            ),
    );
  }
}

class _InfoCardHeader extends StatelessWidget {
  const _InfoCardHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.compact = false,
  });

  final String icon;
  final String title;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 10.r : 14.r;
    final iconSize = compact
        ? AppDimens.iconSizeExtraSmall
        : AppDimens.iconSizeSmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: radius,
          child: SvgPicture.asset(
            icon,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: compact ? AppDimens.marginSmall : 10),
        Flexible(
          child: Text(
            title,
            maxLines: AppDimens.maxLinesShort,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: compact
                ? Theme.of(context).textTheme.titleSmall
                : TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
          ),
        ),
      ],
    );
  }
}
