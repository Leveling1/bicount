import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/open_friend_detail.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';

class FriendListCard extends StatelessWidget {
  const FriendListCard({super.key, required this.friends});

  final List<FriendsModel> friends;

  @override
  Widget build(BuildContext context) {
    final realFriends = friends
        .where((friend) => friend.relationType == FriendConst.friend)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.friendCurrentFriends,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimens.marginSmall),
        DetailsCard(
          child: realFriends.isEmpty
              ? Text(
                  context.l10n.friendCurrentEmpty,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Column(
                  children: realFriends.take(4).map((friend) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FriendCard(
                        friend: friend,
                        onTap: () => openFriendDetail(context, friend),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
