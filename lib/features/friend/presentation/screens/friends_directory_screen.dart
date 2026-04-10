import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/domain/services/friend_view_service.dart';
import 'package:bicount/features/friend/presentation/screens/detail_friend.dart';
import 'package:bicount/features/friend/presentation/screens/friend_screen.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_card.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_directory_header.dart';
import 'package:bicount/features/friend/presentation/widgets/friends_directory_skeleton.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsDirectoryScreen extends StatefulWidget {
  const FriendsDirectoryScreen({super.key});

  @override
  State<FriendsDirectoryScreen> createState() => _FriendsDirectoryScreenState();
}

class _FriendsDirectoryScreenState extends State<FriendsDirectoryScreen> {
  static const _viewService = FriendViewService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query != _searchQuery) {
      setState(() => _searchQuery = query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final data = state is MainLoaded ? state.startData : null;
        final allFriends = data == null
            ? const <FriendsModel>[]
            : _viewService.visibleFriends(
                data.friends,
                currentUserUid: data.user.uid,
              );
        final friends = _searchQuery.isEmpty
            ? allFriends
            : allFriends
                  .where(
                    (f) =>
                        f.username.toLowerCase().contains(_searchQuery) ||
                        f.email.toLowerCase().contains(_searchQuery),
                  )
                  .toList();
        final linkedCount = data == null
            ? 0
            : allFriends
                  .where((friend) => !_viewService.isShareableFriend(friend))
                  .length;

        return Scaffold(
          appBar: CustomAppBar(
            title: context.l10n.friendsTitle,
            actions: [
              if (data != null)
                IconButton(
                  onPressed: () => _openInviteHub(context),
                  icon: const Icon(Icons.qr_code_2_outlined),
                ),
            ],
          ),
          body: data == null
              ? const FriendsDirectorySkeleton()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BicountReveal(
                          delay: const Duration(milliseconds: 30),
                          child: FriendDirectoryHeader(
                            total: friends.length,
                            linked: linkedCount,
                            unlinked: friends.length - linkedCount,
                          ),
                        ),
                        const SizedBox(height: AppDimens.marginLarge),
                        BicountReveal(
                          delay: const Duration(milliseconds: 90),
                          child: Text(
                            context.l10n.friendsDirectoryIntro,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppDimens.marginLarge),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: context.l10n.friendsSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppDimens.marginLarge),
                        Expanded(
                          child: friends.isEmpty
                              ? BicountReveal(
                                  delay: const Duration(milliseconds: 140),
                                  child: DetailsCard(
                                    child: Text(
                                      _searchQuery.isEmpty
                                          ? context.l10n.friendsDirectoryEmpty
                                          : context.l10n.friendsSearchEmpty,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: friends.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final friend = friends[index];
                                    return BicountReveal(
                                      delay: Duration(
                                        milliseconds: 140 + (index * 35),
                                      ),
                                      child: FriendCard(
                                        friend: friend,
                                        onTap: () =>
                                            _openDetail(context, friend),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, FriendsModel friend) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailFriend(friend: friend)));
  }

  void _openInviteHub(BuildContext context) {
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
      ),
    );
  }
}
