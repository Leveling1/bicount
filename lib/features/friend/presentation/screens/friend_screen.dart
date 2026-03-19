import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_invite_preview_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_invite_section.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_list_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_qr_scanner_sheet.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_share_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      if (widget.initialInviteCode != null && widget.initialInviteCode!.isNotEmpty) {
        context.read<FriendBloc>().add(
          FriendInviteCodeReceived(widget.initialInviteCode!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final realtimeFriends = context.select<MainBloc, List<FriendsModel>>((bloc) {
      final state = bloc.state;
      if (state is MainLoaded) {
        return state.startData.friends;
      }
      return widget.friends;
    });

    final visibleFriends = realtimeFriends
        .where((friend) => widget.user == null || friend.uid != widget.user!.uid)
        .toList()
      ..sort(
        (left, right) => ((right.give ?? 0) - (right.receive ?? 0))
            .compareTo((left.give ?? 0) - (left.receive ?? 0)),
      );

    return BlocConsumer<FriendBloc, FriendState>(
      listener: _onStateChanged,
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
                  FriendShareCard(
                    state: state,
                    onCreate: _createInvite,
                    onShare: () => _shareInvite(state.hub.activeShare),
                    onCopy: () => _copyInvite(state.hub.activeShare),
                    onScan: _openScanner,
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                if (state.invitePreview != null) ...[
                  FriendInvitePreviewCard(
                    invite: state.invitePreview!,
                    isSubmitting: state.isSubmitting,
                    onAccept: () {
                      context.read<FriendBloc>().add(const FriendAcceptRequested());
                    },
                    onReject: () {
                      context.read<FriendBloc>().add(const FriendRejectRequested());
                    },
                    onClose: () {
                      context.read<FriendBloc>().add(const FriendPreviewCleared());
                    },
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                FriendInviteSection(
                  title: 'Pending requests',
                  emptyLabel: 'No incoming invitations for now.',
                  invites: state.hub.receivedInvites,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                FriendInviteSection(
                  title: 'Sent invitations',
                  emptyLabel: 'You have not shared a profile link yet.',
                  invites: state.hub.sentInvites,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                FriendListCard(friends: visibleFriends),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, FriendState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      NotificationHelper.showFailureNotification(context, state.errorMessage!);
    }
    if (state.flashMessage != null && state.flashMessage!.isNotEmpty) {
      NotificationHelper.showSuccessNotification(context, state.flashMessage!);
    }
  }

  void _createInvite() {
    final user = widget.user;
    if (user == null) {
      return;
    }
    context.read<FriendBloc>().add(
      FriendCreateInviteRequested(
        senderName: user.username,
        senderEmail: user.email,
        senderImage: user.image,
      ),
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
    NotificationHelper.showSuccessNotification(context, 'Invitation link copied.');
  }

  Future<void> _openScanner() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FriendQrScannerSheet(
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
