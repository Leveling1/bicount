import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:flutter/material.dart';

class FriendInviteSection extends StatelessWidget {
  const FriendInviteSection({
    super.key,
    required this.title,
    required this.emptyLabel,
    required this.invites,
  });

  final String title;
  final String emptyLabel;
  final List<FriendInviteEntity> invites;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.marginSmall),
        DetailsCard(
          child: invites.isEmpty
              ? Text(emptyLabel, style: Theme.of(context).textTheme.bodySmall)
              : Column(
                  children: invites.map((invite) {
                    final title = invite.isFriendProfileInvite
                        ? invite.linkedProfileName
                        : invite.senderName;
                    final subtitle = invite.isFriendProfileInvite
                        ? context.l10n.friendSharedBy(
                            context.friendInviteStatusLabel(invite.status),
                            invite.senderName,
                          )
                        : context.friendInviteStatusLabel(invite.status);
                    final avatar = invite.isFriendProfileInvite
                        ? invite.sourceFriendImage
                        : invite.senderImage;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          AppAvatar(
                            image: (avatar ?? '').isEmpty ? null : avatar,
                            radius: 18,
                            fallbackIcon: Icons.person_outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(invite.createdAt),
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
