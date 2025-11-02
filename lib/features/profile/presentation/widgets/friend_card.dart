import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendCard extends StatelessWidget {
  final FriendsModel friend;
  final VoidCallback onTap;
  const FriendCard({super.key, required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12,),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              radius: 20,
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: Image.asset(friend.image),
              ),
            ),
            const SizedBox(width: 12),

            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friend.email,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
