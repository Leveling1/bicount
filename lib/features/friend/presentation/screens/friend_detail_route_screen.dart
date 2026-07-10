import 'package:bicount/features/friend/presentation/screens/detail_friend.dart';
import 'package:bicount/features/friend/presentation/widgets/detail_friend_skeleton.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendDetailRouteScreen extends StatelessWidget {
  const FriendDetailRouteScreen({super.key, required this.sid});

  final String sid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is! MainLoaded) {
          return const Scaffold(body: DetailFriendSkeleton());
        }

        FriendsModel? found;
        for (final friend in state.startData.friends) {
          if (friend.sid == sid) {
            found = friend;
            break;
          }
        }

        if (found == null) {
          return const Scaffold(body: DetailFriendSkeleton());
        }

        return DetailFriend(friend: found);
      },
    );
  }
}
