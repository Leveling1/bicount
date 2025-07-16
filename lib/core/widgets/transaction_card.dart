import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    String sign = transaction.type == Constants.expenseType ? '-' : '+';
    String time = TimeOfDay.fromDateTime(transaction.date).format(context);
    return InkWell(
      onTap: (){
        context.push('/transactionDetail', extra: transaction);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: Image.asset(transaction.image),
              ),
            ),
            const SizedBox(width: 12),

            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign ${transaction.amount}',
                  style: TextStyle(
                    color: sign == "+"
                        ? AppColors.primaryColorDark
                        : AppColors.negativeColorDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  transaction.type,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
