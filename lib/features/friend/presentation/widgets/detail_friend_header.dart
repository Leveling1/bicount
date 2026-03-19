import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';

class DetailFriendHeader extends StatelessWidget {
  const DetailFriendHeader({
    super.key,
    required this.friend,
    required this.isLinkedProfile,
  });

  final FriendsModel friend;
  final bool isLinkedProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppAvatar(
          image: friend.image.isEmpty ? null : friend.image,
          radius: 40,
          fallbackIcon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        Text(friend.username, style: Theme.of(context).textTheme.titleMedium),
        if (friend.email.isNotEmpty) const SizedBox(height: 4),
        if (friend.email.isNotEmpty)
          Text(friend.email, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Chip(
          backgroundColor: Theme.of(context).cardColor,
          avatar: Icon(
            isLinkedProfile ? Icons.verified_user_outlined : Icons.link_off,
            size: 18,
          ),
          label: Text(isLinkedProfile ? 'Linked account' : 'Local friend'),
        ),
      ],
    );
  }
}
