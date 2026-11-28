import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/formated_text.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/custom_tool_tip.dart';
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
          radius: AppSizes.dp40,
          fallbackIcon: Icons.person_outline,
        ),
        const SizedBox(height: AppSizes.dp12),
        Text(
          FormatedText().capitalizeFirstLetter(friend.username),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (friend.email.isNotEmpty)
          const SizedBox(height: AppDimens.spacingExtraSmall),
        if (friend.email.isNotEmpty)
          Text(friend.email, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSizes.dp12),
        isLinkedProfile
            ? _buildChip(context)
            : CustomToolTip(
                text: context.l10n.friendLinkHint,
                child: _buildChip(context),
              ),
      ],
    );
  }

  Widget _buildChip(BuildContext context) {
    return Chip(
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide.none,
      avatar: Icon(
        isLinkedProfile ? Icons.verified_user_outlined : Icons.link_off,
        size: AppSizes.dp18,
      ),
      label: Text(
        isLinkedProfile
            ? context.l10n.friendLinkedAccount
            : context.l10n.friendLocalFriend,
      ),
    );
  }
}
