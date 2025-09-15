import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/utils/number_format_utils.dart';
import '../../../../core/widgets/details_card.dart';

class CompanyCardInfo extends StatelessWidget {
  final String title;
  final double value;
  final double percent;
  final Color color;
  const CompanyCardInfo({
    super.key,
    required this.color,
    required this.title,
    required this.value,
    required this.percent
  });

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormatUtils.formatCurrency(value as num),
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "$percent%",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  "assets/icons/company_card_icon.svg",
                  semanticsLabel: "Company",
                  width: 50.w,
                  height: 50.h,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).cardColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
