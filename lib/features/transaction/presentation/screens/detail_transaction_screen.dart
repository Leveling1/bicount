import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../domain/entities/transaction_detail_args.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/widgets/details_card.dart';

class DetailTransactionScreen extends StatelessWidget {
  const DetailTransactionScreen({super.key, required this.transaction});

  final TransactionDetailArgs transaction;

  @override
  Widget build(BuildContext context) {
    const double size = 20;
    final data = transaction.transactionDetail;
    final supabaseInstance = Supabase.instance.client;
    final uid = supabaseInstance.auth.currentUser!.id;
    final formattedDate = formatedDate(data.date);
    final formattedTime = formatedTime(data.date);
    final formattedCreatedDateTime = formatedDateTime(data.createdAt!);
    final sign = data.sender == uid
        ? '-'
        : data.beneficiary == uid
        ? '+'
        : '';

    final ourData = FriendsModel(
      sid: transaction.user.sid,
      username: transaction.user.username,
      uid: transaction.user.uid,
      image: transaction.user.image,
      email: transaction.user.email,
      relationType: FriendConst.friend,
    );
    final sender = transaction.friends
        .firstWhere(
          (friend) => friend.sid == data.sender,
          orElse: () => ourData,
        )
        .username;
    final beneficiary = transaction.friends
        .firstWhere(
          (friend) => friend.sid == data.beneficiary,
          orElse: () => ourData,
        )
        .username;

    return Column(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                data.sender == uid || data.uid == uid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).iconTheme.color,
                              size: size,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                        : CachedNetworkImage(
                            imageUrl: data.image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  '$sign ${data.amount} ${data.currency.symbol}',
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
                      RowDetail(
                        title: context.l10n.commonDate,
                        content: formattedDate,
                      ),
                      const SizedBox(height: 8),
                      RowDetail(
                        title: context.l10n.commonTime,
                        content: formattedTime,
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(
                        title: context.l10n.commonSender,
                        content: sender,
                      ),
                      const SizedBox(height: 8),
                      RowDetail(
                        title: context.l10n.commonBeneficiary,
                        content: beneficiary,
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(
                        title: context.l10n.commonFrequency,
                        content: context.frequencyLabel(data.frequency!),
                      ),
                      if (data.note.isNotEmpty) const SizedBox(height: 8),
                      if (data.note.isNotEmpty)
                        RowDetail(
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
}

class RowDetail extends StatelessWidget {
  const RowDetail({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Flexible(
          flex: 2,
          child: Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
