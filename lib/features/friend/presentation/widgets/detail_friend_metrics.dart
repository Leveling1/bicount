import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/friend/domain/entities/friend_detail_entity.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class DetailFriendMetrics extends StatelessWidget {
  const DetailFriendMetrics({super.key, required this.detail});

  final FriendDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: InfoCardAmount(
                icon: IconLinks.expense,
                title: context.l10n.friendGiven,
                value: detail.totalGiven,
                currencyCode: detail.displayCurrencyCode,
                color: Theme.of(context).extension<OtherTheme>()!.expense!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              child: InfoCardAmount(
                icon: IconLinks.income,
                title: context.l10n.friendReceived,
                value: detail.totalReceived,
                currencyCode: detail.displayCurrencyCode,
                color: Theme.of(context).extension<OtherTheme>()!.income!,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: InfoCardAmount(
                icon: IconLinks.user,
                title: context.l10n.profilePersonal,
                value: detail.friend.personalIncome ?? 0,
                currencyCode: detail.displayCurrencyCode,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.personnalIncome!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              child: InfoCardAmount(
                icon: IconLinks.wallet,
                title: context.l10n.friendNet,
                value: detail.netBalance,
                currencyCode: detail.displayCurrencyCode,
                color: detail.netBalance >= 0
                    ? Theme.of(context).extension<OtherTheme>()!.income!
                    : Theme.of(context).extension<OtherTheme>()!.expense!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
