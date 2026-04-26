import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class FriendCard extends StatelessWidget {
  final FriendsModel friend;
  final VoidCallback onTap;
  const FriendCard({super.key, required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final give = NumberFormatUtils.formatCurrency(friend.give ?? 0);
    final receive = NumberFormatUtils.formatCurrency(friend.receive ?? 0);
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
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
                AppAvatar(
                  image: friend.relationType == FriendConst.subscription
                      ? null
                      : friend.image,
                  radius: 20,
                  fallbackIcon: friend.relationType == FriendConst.subscription
                      ? Icons.subscriptions
                      : Icons.person_outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        friend.relationType == FriendConst.subscription
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
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
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    Text(
                                      '${context.l10n.friendGiven}: ',
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
                                        color: give == '0.00'
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
                                    ? '${context.l10n.subscriptionCumulativeExpenses}: '
                                    : '${context.l10n.friendReceived}: ',
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
                                  color: receive == '0.00'
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
