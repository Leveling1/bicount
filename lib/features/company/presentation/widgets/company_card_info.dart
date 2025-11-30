import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconPath;
    switch (title) {
      case "Profit":
        iconPath = Icons.trending_up;
        break;
      case "Salary":
        iconPath = Icons.account_balance_wallet;
        break;
      case "Equipment":
        iconPath = Icons.build;
        break;
      default: // "Third-party service" or any other case
        iconPath = Icons.work;
    }
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$percent%",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  fontWeight: FontWeight.bold,
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
            radius: 20.r, // Using .r for radius to scale consistently
            child: Icon(
              iconPath,
              size: 24.sp, // Adjust size to fit within the avatar
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
