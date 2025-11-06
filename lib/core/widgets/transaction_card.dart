import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:go_router/go_router.dart';

import '../../features/main/data/models/friends.model.dart';
import '../../features/transaction/data/models/transaction.model.dart';
import '../../features/transaction/domain/entities/transaction_detail_args.dart';
import '../themes/app_dimens.dart';

class TransactionCard extends StatelessWidget {
  final List<FriendsModel> friends;
  final TransactionEntity transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.friends
  });

  @override
  Widget build(BuildContext context) {
    String sign = transaction.type == TransactionType.expense ? '-' : '+';
    String time = TimeOfDay.fromDateTime(transaction.date).format(context);
    String currency = transaction.currency.symbol;
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: () {
            context.push(
              '/transactionDetail',
              extra: TransactionDetailArgs(
                transaction: transaction,
                friends: friends,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 20,
                  child: SizedBox(
                    width: 30.w,
                    height: 30.h,
                    child: Image.asset(transaction.image!),
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
                      '$sign ${transaction.amount} $currency',
                      style: TextStyle(
                        color: sign == "+"
                            ? AppColors.primaryColorDark
                            : AppColors.negativeColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      transaction.type.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============= For the loading ============= ///
class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 🟣 Avatar placeholder
            SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),

            // 🟢 Name + Date placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 14,
                      width: 120,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 12,
                      width: 60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // 🟠 Amount + Type placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 14,
                    width: 50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 12,
                    width: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
