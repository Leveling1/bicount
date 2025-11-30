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
                    child: CachedNetworkImage(
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
                          Text(
                            'Given: $give',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),

                          Text(
                            'Received: $receive',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
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
