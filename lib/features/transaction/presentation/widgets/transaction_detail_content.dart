import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_detail_args.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionDetailContent extends StatelessWidget {
  const TransactionDetailContent({
    super.key,
    required this.transaction,
    required this.canEdit,
    this.onEditPressed,
  });

  final TransactionDetailArgs transaction;
  final bool canEdit;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 20;
    final data = transaction.transactionDetail;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final formattedDate = formatedDate(data.date);
    final formattedTime = formatedTime(data.date);
    final formattedCreatedDateTime = formatedDateTime(data.createdAt!);
    final sign = data.sender == uid
        ? '-'
        : data.beneficiary == uid
        ? '+'
        : '';

    final currentUser = FriendsModel(
      sid: transaction.user.uid,
      username: transaction.user.username,
      uid: transaction.user.uid,
      image: transaction.user.image,
      email: transaction.user.email,
      relationType: FriendConst.friend,
    );
    final sender = _resolvePartyName(data.sender, currentUser);
    final beneficiary = _resolvePartyName(data.beneficiary, currentUser);
    final amount = NumberFormatUtils.formatCurrency(
      data.amount,
      currencyCode: data.currency,
    );

    return Column(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (canEdit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onEditPressed,
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).iconTheme.color,
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 40,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: data.type == TransactionTypes.subscriptionCode
                        ? Icon(
                            Icons.subscriptions,
                            color: Theme.of(context).primaryColor,
                          )
                        : data.image?.isNotEmpty == true
                        ? AppAvatar(image: data.image!, radius: 40)
                        : Icon(
                            Icons.payments_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  '$sign $amount',
                  style: TextStyle(
                    color: sign == '+'
                        ? AppColors.primaryColorDark
                        : sign == '-'
                        ? AppColors.negativeColorDark
                        : Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.transactionTypeLabel(data.type),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      TransactionDetailRow(
                        title: context.l10n.commonDate,
                        content: formattedDate,
                      ),
                      const SizedBox(height: 8),
                      TransactionDetailRow(
                        title: context.l10n.commonTime,
                        content: formattedTime,
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      TransactionDetailRow(
                        title: context.l10n.commonSender,
                        content: sender,
                      ),
                      const SizedBox(height: 8),
                      TransactionDetailRow(
                        title: context.l10n.commonBeneficiary,
                        content: beneficiary,
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      TransactionDetailRow(
                        title: context.l10n.commonFrequency,
                        content: context.frequencyLabel(data.frequency!),
                      ),
                      if (data.note.isNotEmpty) const SizedBox(height: 8),
                      if (data.note.isNotEmpty)
                        TransactionDetailRow(
                          title: context.l10n.commonNote,
                          content: data.note,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.commonCreatedAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              formattedCreatedDateTime,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingLarge),
      ],
    );
  }

  String _resolvePartyName(String partyId, FriendsModel fallback) {
    return transaction.friends
        .firstWhere(
          (friend) => friend.sid == partyId || friend.uid == partyId,
          orElse: () => fallback,
        )
        .username;
  }
}
