import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({
    super.key,
    this.user,
    this.friends = const [],
    this.initialInviteCode,
  });

  final UserModel? user;
  final List<FriendsModel> friends;
  final String? initialInviteCode;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialInviteCode != null &&
          widget.initialInviteCode!.isNotEmpty) {
        context.read<FriendBloc>().add(
          FriendInviteCodeReceived(widget.initialInviteCode!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final realtimeFriends = context.select<MainBloc, List<FriendsModel>>((
      bloc,
    ) {
      final state = bloc.state;
      if (state is MainLoaded) {
        return state.startData.friends;
      }
      return widget.friends;
    });

    final visibleFriends =
        realtimeFriends
            .where(
              (friend) => widget.user == null || friend.uid != widget.user!.uid,
            )
            .toList()
          ..sort(
            (left, right) => ((right.give ?? 0) - (right.receive ?? 0))
                .compareTo((left.give ?? 0) - (left.receive ?? 0)),
          );

    return BlocConsumer<FriendBloc, FriendState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          NotificationHelper.showFailureNotification(
            context,
            state.errorMessage!,
          );
        }
        if (state.flashMessage != null && state.flashMessage!.isNotEmpty) {
          NotificationHelper.showSuccessNotification(
            context,
            state.flashMessage!,
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingMedium,
              AppDimens.paddingMedium,
              AppDimens.paddingMedium,
              AppDimens.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Friends', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimens.marginSmall),
                Text(
                  'Share your Bicount profile, scan a QR code, or accept an invitation link.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                if (widget.user != null) ...[
                  _ShareCard(
                    state: state,
                    onCreate: () {
                      context.read<FriendBloc>().add(
                        FriendCreateInviteRequested(
                          senderName: widget.user!.username,
                          senderEmail: widget.user!.email,
                          senderImage: widget.user!.image,
                        ),
                      );
                    },
                    onShare: () => _shareInvite(state.hub.activeShare),
                    onCopy: () => _copyInvite(state.hub.activeShare),
                    onScan: _openScanner,
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                if (state.invitePreview != null) ...[
                  _InvitePreviewCard(
                    invite: state.invitePreview!,
                    isSubmitting: state.isSubmitting,
                    onAccept: () {
                      context.read<FriendBloc>().add(
                        const FriendAcceptRequested(),
                      );
                    },
                    onReject: () {
                      context.read<FriendBloc>().add(
                        const FriendRejectRequested(),
                      );
                    },
                    onClose: () {
                      context.read<FriendBloc>().add(
                        const FriendPreviewCleared(),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                _InviteSection(
                  title: 'Pending requests',
                  emptyLabel: 'No incoming invitations for now.',
                  invites: state.hub.receivedInvites,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                _InviteSection(
                  title: 'Sent invitations',
                  emptyLabel: 'You have not shared a profile link yet.',
                  invites: state.hub.sentInvites,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                _FriendListCard(friends: visibleFriends),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyInvite(FriendShareEntity? share) async {
    if (share == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: share.inviteUrl));
    if (!mounted) {
      return;
    }
    NotificationHelper.showSuccessNotification(
      context,
      'Invitation link copied.',
    );
  }

  Future<void> _openScanner() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _QrScannerSheet(
          onValue: (value) {
            context.read<FriendBloc>().add(FriendInviteCodeReceived(value));
          },
        );
      },
    );
  }

  Future<void> _shareInvite(FriendShareEntity? share) async {
    if (share == null) {
      return;
    }

    await Share.share(
      'Join me on Bicount and connect with my profile: ${share.inviteUrl}',
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.state,
    required this.onCreate,
    required this.onShare,
    required this.onCopy,
    required this.onScan,
  });

  final FriendState state;
  final VoidCallback onCreate;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final activeShare = state.hub.activeShare;

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share your profile',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate a reusable invitation, then share it as a link or a QR code.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.marginLarge),
          if (activeShare != null) ...[
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusLarge,
                  ),
                ),
                child: QrImageView(
                  data: activeShare.inviteUrl,
                  size: 180,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).primaryColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.marginMedium),
            Text(
              activeShare.inviteUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimens.marginMedium),
          ],
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              ElevatedButton.icon(
                onPressed: state.isSubmitting ? null : onCreate,
                icon: const Icon(Icons.link_outlined),
                label: Text(
                  activeShare == null ? 'Generate invite' : 'Refresh',
                ),
              ),
              ElevatedButton.icon(
                onPressed: activeShare == null ? null : onShare,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Share link'),
              ),
              OutlinedButton.icon(
                onPressed: activeShare == null ? null : onCopy,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy'),
              ),
              OutlinedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Scan QR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitePreviewCard extends StatelessWidget {
  const _InvitePreviewCard({
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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

class _InviteSection extends StatelessWidget {
  const _InviteSection({
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          AppAvatar(
                            image: invite.senderImage.isEmpty
                                ? null
                                : invite.senderImage,
                            radius: 18,
                            fallbackIcon: Icons.person_outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invite.senderName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  invite.status.label,
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

class _FriendListCard extends StatelessWidget {
  const _FriendListCard({required this.friends});

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
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
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

class _QrScannerSheet extends StatefulWidget {
  const _QrScannerSheet({required this.onValue});

  final ValueChanged<String> onValue;

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.borderRadiusExtraLarge),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimens.marginMedium),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
          Text(
            'Scan invitation QR code',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.marginMedium),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimens.borderRadiusExtraLarge,
              ),
              child: MobileScanner(
                onDetect: (capture) {
                  if (_handled) {
                    return;
                  }
                  final value = capture.barcodes.first.rawValue;
                  if (value == null || value.isEmpty) {
                    return;
                  }
                  _handled = true;
                  widget.onValue(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
        ],
      ),
    );
  }
}
