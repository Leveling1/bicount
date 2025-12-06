import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            child: CachedNetworkImage(
              imageUrl: friend.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(friend.username, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        friend.email.isNotEmpty
            ? Text(friend.email, style: Theme.of(context).textTheme.titleSmall)
            : const SizedBox.shrink(),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: InfoCardAmount(
                icon: IconLinks.expense,
                title: 'Given',
                value: friend.give!,
                color: Theme.of(context).extension<OtherTheme>()!.expense!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              flex: 1,
              child: InfoCardAmount(
                icon: IconLinks.income,
                title: 'Received',
                value: friend.receive!,
                color: Theme.of(context).extension<OtherTheme>()!.income!,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: InfoCardAmount(
                icon: IconLinks.user,
                title: 'Personal',
                value: friend.personalIncome!,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.personnalIncome!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              flex: 1,
              child: InfoCardAmount(
                icon: IconLinks.company,
                title: 'Company',
                value: friend.companyIncome!,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.companyIncome!,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.marginLarge),
      ],
    );
  }
}
