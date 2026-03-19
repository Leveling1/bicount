import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';

class FriendListCard extends StatelessWidget {
  const FriendListCard({super.key, required this.friends});

  final List<FriendsModel> friends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current friends', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.marginSmall),
        DetailsCard(
          child: friends.isEmpty
              ? Text(
                  'Your accepted contacts will show up here in real time.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Column(
                  children: friends.take(4).map((friend) {
                    final balance = (friend.receive ?? 0) - (friend.give ?? 0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          AppAvatar(
                            image: friend.image.isEmpty ? null : friend.image,
                            radius: 18,
                            fallbackIcon: Icons.person_outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.username,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  friend.email,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            NumberFormatUtils.formatCurrency(balance),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
