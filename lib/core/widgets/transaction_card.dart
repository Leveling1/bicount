import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionCard extends StatelessWidget {
  final String name;
  final String date;
  final String amount;
  final String type;
  final String image;

  const TransactionCard({
    super.key,
    required this.name,
    required this.date,
    required this.amount,
    required this.type,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    String sign = type == Constants.expenseType ? '-' : '+';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        /*border: Border(
          bottom: BorderSide(color: Theme.of(context).cardColor, width: 0.5),
        ),*/
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 20,
            child: SizedBox(
              width: 30.w,
              height: 30.h,
              child: Image.asset(image),
            ),
          ),
          const SizedBox(width: 12),

          // Name and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '$sign $amount',
            style: TextStyle(
              color: sign == "+"
                  ? AppColors.primaryColorDark
                  : AppColors.negativeColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
