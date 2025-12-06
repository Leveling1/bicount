import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/number_format_utils.dart';
import '../../../../core/widgets/details_card.dart';

class InfoCardAmount extends StatelessWidget {
  final String icon;
  final String title;
  final double value;
  final Color color;

  const InfoCardAmount({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 14.r, // Using .r for radius to scale consistently
                child: SvgPicture.asset(
                  icon,
                  width: AppDimens.iconSizeSmall,
                  height: AppDimens.iconSizeSmall,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            NumberFormatUtils.formatCurrency(value as num),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final Color color;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 14.r, // Using .r for radius to scale consistently
                child: SvgPicture.asset(
                  icon,
                  width: AppDimens.iconSizeSmall,
                  height: AppDimens.iconSizeSmall,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class InfoCardNote extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final Color color;

  const InfoCardNote({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 14.r, // Using .r for radius to scale consistently
                child: SvgPicture.asset(
                  icon,
                  width: AppDimens.iconSizeSmall,
                  height: AppDimens.iconSizeSmall,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}


class LinearInfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final Color color;

  const LinearInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return         DetailsCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 10.r, // Using .r for radius to scale consistently
                    child: SvgPicture.asset(
                      icon,
                      width: AppDimens.iconSizeExtraSmall,
                      height: AppDimens.iconSizeExtraSmall,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.marginSmall),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(width: AppDimens.marginSmall),
              Text(
                content,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
  }
}