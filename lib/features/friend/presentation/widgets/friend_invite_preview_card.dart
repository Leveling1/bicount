import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:flutter/material.dart';

class FriendInvitePreviewCard extends StatelessWidget {
  const FriendInvitePreviewCard({
    super.key,
    required this.invite,
    required this.isSubmitting,
    required this.onAccept,
    required this.onReject,
    required this.onClose,
  });

  final FriendInviteEntity invite;
  final bool isSubmitting;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invitation preview',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppDimens.marginMedium),
          Row(
            children: [
              AppAvatar(
                image: invite.senderImage.isEmpty ? null : invite.senderImage,
                radius: 22,
                fallbackIcon: Icons.person_outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.senderName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invite.senderEmail,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (invite.isFriendProfileInvite) ...[
            const SizedBox(height: AppDimens.marginMedium),
            Text(
              'Profile to link: ${invite.linkedProfileName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if ((invite.sourceFriendEmail ?? '').isNotEmpty)
              const SizedBox(height: 4),
            if ((invite.sourceFriendEmail ?? '').isNotEmpty)
              Text(
                invite.sourceFriendEmail!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
          const SizedBox(height: AppDimens.marginMedium),
          Text(
            'This invite expires on ${MaterialLocalizations.of(context).formatMediumDate(invite.expiresAt)}.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.marginLarge),
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              ElevatedButton(
                onPressed: invite.isPending && !isSubmitting ? onAccept : null,
                child: const Text('Accept'),
              ),
              OutlinedButton(
                onPressed: invite.isPending && !isSubmitting ? onReject : null,
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
