import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
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
                  context.l10n.friendInvitePreview,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              BicountPressable.button(
                builder: (statesController) => IconButton(
                  statesController: statesController,
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.marginMedium),
          Row(
            children: [
              AppAvatar(
                image: invite.senderImage.isEmpty ? null : invite.senderImage,
                radius: AppSizes.dp22,
                fallbackIcon: Icons.person_outline,
              ),
              const SizedBox(width: AppSizes.dp12),
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
                    const SizedBox(height: AppSizes.dp2),
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
              context.l10n.friendProfileToLink(invite.linkedProfileName),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if ((invite.sourceFriendEmail ?? '').isNotEmpty)
              const SizedBox(height: AppDimens.spacingExtraSmall),
            if ((invite.sourceFriendEmail ?? '').isNotEmpty)
              Text(
                invite.sourceFriendEmail!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
          const SizedBox(height: AppDimens.marginMedium),
          Text(
            context.l10n.friendInviteExpiresOn(
              MaterialLocalizations.of(
                context,
              ).formatMediumDate(invite.expiresAt),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.marginLarge),
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              BicountPressable.button(
                builder: (statesController) => ElevatedButton(
                  statesController: statesController,
                  onPressed: invite.isPending && !isSubmitting
                      ? onAccept
                      : null,
                  child: Text(context.l10n.commonAccept),
                ),
              ),
              BicountPressable.button(
                builder: (statesController) => OutlinedButton(
                  statesController: statesController,
                  onPressed: invite.isPending && !isSubmitting
                      ? onReject
                      : null,
                  child: Text(context.l10n.commonReject),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
