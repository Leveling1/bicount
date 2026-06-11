import 'package:bicount/features/friend/presentation/screens/detail_friend.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';

void openFriendDetail(BuildContext context, FriendsModel friend) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => DetailFriend(friend: friend)));
}
