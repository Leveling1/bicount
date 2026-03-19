import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/domain/services/friend_view_service.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/friend/presentation/helpers/friend_screen_actions.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_invite_preview_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_invite_section.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_list_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_screen_intro.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_share_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({
    super.key,
    this.user,
    this.friends = const [],
    this.initialInviteCode,
    this.selectedFriend,
  });

  final UserModel? user;
  final List<FriendsModel> friends;
  final String? initialInviteCode;
  final FriendsModel? selectedFriend;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  static const _viewService = FriendViewService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inviteCode = widget.initialInviteCode;
      if (inviteCode != null && inviteCode.isNotEmpty) {
        context.read<FriendBloc>().add(FriendInviteCodeReceived(inviteCode));
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

    final visibleFriends = _viewService.visibleFriends(
      realtimeFriends,
      currentUserUid: widget.user?.uid,
      currentUserSid: widget.user?.sid,
    );

    return BlocConsumer<FriendBloc, FriendState>(
      listener: handleFriendStateFeedback,
      builder: (context, state) {
        final activeShare = _resolveActiveShare(state.hub.activeShare);
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FriendScreenIntro(
                  title: widget.selectedFriend == null
                      ? 'Friend invitations'
                      : 'Link ${widget.selectedFriend!.username}',
                  description: widget.selectedFriend == null
                      ? 'Scan an invite, review pending links, and track shared profiles in real time.'
                      : 'Share this local friend profile when the person has created a Bicount account so the backend can link both profiles together.',
                ),
                const SizedBox(height: AppDimens.marginLarge),
                if (widget.user != null && widget.selectedFriend != null) ...[
                  FriendShareCard(
                    title: 'Share ${widget.selectedFriend!.username} profile',
                    description:
                        'Generate a QR code or a link for this specific friend profile.',
                    activeShare: activeShare,
                    isSubmitting: state.isSubmitting,
                    onCreate: _createInvite,
                    onShare: () => shareFriendInvite(activeShare),
                    onCopy: () => copyFriendInvite(context, activeShare),
                    onScan: () => openFriendScanner(
                      context,
                      onValue: _onInviteValueReceived,
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                if (widget.user != null && widget.selectedFriend == null) ...[
                  OutlinedButton.icon(
                    onPressed: () => openFriendScanner(
                      context,
                      onValue: _onInviteValueReceived,
                    ),
                    icon: const Icon(Icons.qr_code_scanner_outlined),
                    label: const Text('Scan invite'),
                  ),
                  const SizedBox(height: AppDimens.marginLarge),
                ],
                if (state.invitePreview != null) ...[
                  FriendInvitePreviewCard(
                    invite: state.invitePreview!,
                    isSubmitting: state.isSubmitting,
                    onAccept: () => context.read<FriendBloc>().add(
                      const FriendAcceptRequested(),
                    ),
                    onReject: () => context.read<FriendBloc>().add(
                      const FriendRejectRequested(),
                    ),
                    onClose: () => context.read<FriendBloc>().add(
                      const FriendPreviewCleared(),
                    ),
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
                  emptyLabel: 'You have not shared a friend profile yet.',
                  invites: state.hub.sentInvites,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                FriendListCard(friends: visibleFriends),
                const SizedBox(height: AppDimens.marginLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  FriendShareEntity? _resolveActiveShare(FriendShareEntity? share) {
    final selectedFriend = widget.selectedFriend;
    if (share == null || selectedFriend == null) {
      return share;
    }
    return share.sourceFriendSid == selectedFriend.sid ? share : null;
  }

  void _createInvite() {
    final user = widget.user;
    final friend = widget.selectedFriend;
    if (user == null || friend == null) {
      return;
    }

    context.read<FriendBloc>().add(
      FriendCreateInviteRequested(
        senderName: user.username,
        senderEmail: user.email,
        senderImage: user.image,
        sourceFriendSid: friend.sid,
        sourceFriendName: friend.username,
        sourceFriendEmail: friend.email,
        sourceFriendImage: friend.image,
      ),
    );
  }

  void _onInviteValueReceived(String value) {
    context.read<FriendBloc>().add(FriendInviteCodeReceived(value));
  }
}
