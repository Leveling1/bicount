import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class DetailSubscription extends StatelessWidget {
  final FriendsModel friend;
  final SubscriptionModel subscription;
  const DetailSubscription({
    super.key,
    required this.friend,
    required this.subscription,
  });

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
            child: Icon(
              Icons.subscriptions,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(friend.username, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        friend.email.isNotEmpty
            ? Text(friend.email, style: Theme.of(context).textTheme.titleSmall)
            : const SizedBox.shrink(),

        subscription.notes == "" || subscription.notes == null
            ? const SizedBox.shrink()
            : InfoCardNote(
                icon: IconLinks.note,
                title: 'Note',
                content: subscription.notes!,
                color: Theme.of(context).primaryColor,
              ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: InfoCardAmount(
                icon: IconLinks.moneyIcon,
                title: 'Amount',
                value: subscription.amount,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.personnalIncome!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              flex: 1,
              child: InfoCard(
                icon: IconLinks.calendar,
                title: 'Start date',
                content: subscription.startDate,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.companyIncome!,
              ),
            ),
          ],
        ),
        DetailsCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).extension<OtherTheme>()!.expense!,
                    radius: 10.r, // Using .r for radius to scale consistently
                    child: SvgPicture.asset(
                      IconLinks.expense,
                      width: AppDimens.iconSizeExtraSmall,
                      height: AppDimens.iconSizeExtraSmall,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.marginSmall),
                  Text(
                    'Cumulative expenses',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(width: AppDimens.marginSmall),
              Text(
                NumberFormatUtils.formatCurrency(friend.receive! as num),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.marginMedium),
        CustomButton(text: 'unsubscribe', loading: false, onPressed: () {}),
        const SizedBox(height: AppDimens.marginLarge),
      ],
    );
  }
}
