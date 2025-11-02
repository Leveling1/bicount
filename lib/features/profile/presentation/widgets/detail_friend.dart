import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../main/data/models/friends.model.dart';

class DetailFriend extends StatelessWidget {
  final FriendsModel friend;
  const DetailFriend({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).cardColor,
          radius: 40,
          child: SizedBox(
            width: 50.w,
            height: 50.h,
            child: Image.asset(friend.image),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          friend.username,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        friend.email.isNotEmpty
        ? Text(
          friend.email,
          style: Theme.of(context).textTheme.titleSmall,
        ) : const SizedBox.shrink(),

      ],
    );
  }
}
