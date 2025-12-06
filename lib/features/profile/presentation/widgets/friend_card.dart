import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_dimens.dart';

class FriendCard extends StatelessWidget {
  final FriendsModel friend;
  final VoidCallback onTap;
  const FriendCard({super.key, required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String give = NumberFormatUtils.formatCurrency(friend.give! as num);
    String receive = NumberFormatUtils.formatCurrency(friend.receive! as num);
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: AppDimens.paddingSmallCard,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 20,
                  child: SizedBox(
                    width: 30.w,
                    height: 30.h,
                    child: friend.relationType == FriendConst.subscription
                        ? Icon(
                            Icons.subscriptions,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : CachedNetworkImage(
                            imageUrl: friend.image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        friend.username,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          friend.relationType == FriendConst.subscription
                              ? SizedBox.shrink()
                              : Row(
                                  children: [
                                    Text(
                                      'Given: ',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.color,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      give,
                                      style: TextStyle(
                                        color: give == "0.00"
                                            ? Theme.of(
                                                context,
                                              ).textTheme.bodySmall!.color
                                            : Theme.of(context)
                                                  .extension<OtherTheme>()!
                                                  .expense!,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),

                          Row(
                            children: [
                              Text(
                                friend.relationType == FriendConst.subscription
                                    ? 'Cumulative expenses: '
                                    : 'Received: ',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.color,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                receive,
                                style: TextStyle(
                                  color: receive == "0.00"
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.color
                                      : Theme.of(
                                          context,
                                        ).extension<OtherTheme>()!.income!,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
