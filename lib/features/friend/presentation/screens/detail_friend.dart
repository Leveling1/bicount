import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/domain/services/friend_view_service.dart';
import 'package:bicount/features/friend/presentation/screens/friend_screen.dart';
import 'package:bicount/features/friend/presentation/widgets/detail_friend_skeleton.dart';
import 'package:bicount/features/friend/presentation/widgets/detail_friend_header.dart';
import 'package:bicount/features/friend/presentation/widgets/detail_friend_metrics.dart';
import 'package:bicount/features/friend/presentation/widgets/detail_friend_transaction_section.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_profile_sheet.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailFriend extends StatelessWidget {
  const DetailFriend({super.key, required this.friend});

  final FriendsModel friend;
  static const _viewService = FriendViewService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final data = state is MainLoaded ? state.startData : null;
        final detail = data == null
            ? null
            : _viewService.buildDetail(data: data, fallbackFriend: friend);
        final currentFriend = detail?.friend ?? friend;

        return Scaffold(
          appBar: CustomAppBar(
            title: context.l10n.friendDetailTitle,
            actions: [
              if (detail != null && detail.canShareProfile)
                IconButton(
                  onPressed: () => _openEditFlow(context, currentFriend),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (detail != null && detail.canShareProfile)
                IconButton(
                  onPressed: () => _openShareFlow(context, currentFriend),
                  icon: const Icon(Icons.ios_share_outlined),
                ),
            ],
          ),
          body: data == null || detail == null
              ? const DetailFriendSkeleton()
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                      vertical: AppDimens.paddingMedium,
                    ),
                    children: [
                      BicountReveal(
                        delay: const Duration(milliseconds: 30),
                        child: DetailFriendHeader(
                          friend: currentFriend,
                          isLinkedProfile: detail.isLinkedProfile,
                        ),
                      ),
                      const SizedBox(height: AppDimens.marginLarge),
                      if (detail.canShareProfile)
                        BicountReveal(
                          delay: const Duration(milliseconds: 90),
                          child: DetailsCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.link_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    context.l10n.friendLinkHint,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      BicountReveal(
                        delay: const Duration(milliseconds: 140),
                        child: DetailFriendMetrics(detail: detail),
                      ),
                      const SizedBox(height: AppDimens.marginLarge),
                      BicountReveal(
                        delay: const Duration(milliseconds: 190),
                        child: DetailFriendTransactionSection(
                          detail: detail,
                          user: data.user,
                          friends: data.friends,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _openShareFlow(BuildContext context, FriendsModel currentFriend) {
    final state = context.read<MainBloc>().state;
    if (state is! MainLoaded) {
      return;
    }

    showCustomBottomSheet(
      context: context,
      minHeight: 0.6,
      child: FriendScreen(
        user: state.startData.user,
        friends: state.startData.friends,
        selectedFriend: currentFriend,
      ),
    );
  }

  Future<void> _openEditFlow(
    BuildContext context,
    FriendsModel currentFriend,
  ) async {
    final updated = await showCustomBottomSheet<bool>(
      context: context,
      minHeight: 0.8,
      child: FriendProfileSheet(friend: currentFriend),
    );
    if (updated == true && context.mounted) {
      NotificationHelper.showSuccessNotification(
        context,
        context.l10n.friendProfileUpdated,
      );
    }
  }
}
