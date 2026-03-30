import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/get_new_date.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionDetailView extends StatelessWidget {
  const SubscriptionDetailView({
    super.key,
    required this.friend,
    required this.subscription,
    required this.isUnsubscribing,
    required this.onUnsubscribePressed,
    this.onEditPressed,
  });

  final FriendsModel friend;
  final SubscriptionModel subscription;
  final bool isUnsubscribing;
  final VoidCallback onUnsubscribePressed;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = SubscriptionConst.normalize(subscription.status);
    final badgeColor = SubscriptionConst.getStatusColor(
      normalizedStatus,
      context,
    );

    return Column(
      children: [
        if (SubscriptionConst.isActive(normalizedStatus))
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEditPressed,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
            ],
          ),
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
        const SizedBox(height: AppDimens.paddingSmallMedium),
        Text(friend.username, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimens.paddingExtraSmall),
        Container(
          constraints: const BoxConstraints(minWidth: 70),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            context.subscriptionStatusLabel(normalizedStatus),
            style: TextStyle(color: badgeColor, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          children: [
            Flexible(
              child: InfoCardAmount(
                icon: IconLinks.moneyIcon,
                title: context.l10n.commonAmount,
                value: subscription.amount,
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.personnalIncome!,
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Flexible(
              child: InfoCard(
                icon: IconLinks.calendar,
                title: SubscriptionConst.isActive(normalizedStatus)
                    ? context.l10n.subscriptionNextBilling
                    : context.l10n.subscriptionBillingStop,
                content: SubscriptionConst.isActive(normalizedStatus)
                    ? getNextMonthSameDay(subscription.nextBillingDate)
                    : formatedDateTimeNumericFullYear(
                        DateTime.parse(subscription.endDate!),
                      ),
                color: Theme.of(
                  context,
                ).extension<OtherTheme>()!.companyIncome!,
              ),
            ),
          ],
        ),
        LinearInfoCard(
          icon: IconLinks.frequency,
          title: context.l10n.commonFrequency,
          content: context.frequencyLabel(subscription.frequency),
          color: Theme.of(context).extension<OtherTheme>()!.personnalIncome!,
        ),
        LinearInfoCard(
          icon: IconLinks.expense,
          title: context.l10n.subscriptionCumulativeExpenses,
          content: NumberFormatUtils.formatCurrency(friend.receive! as num),
          color: Theme.of(context).extension<OtherTheme>()!.expense!,
        ),
        if (subscription.notes?.isNotEmpty ?? false)
          InfoCardNote(
            icon: IconLinks.note,
            title: context.l10n.commonNote,
            content: subscription.notes!,
            color: Theme.of(context).primaryColor,
          ),
        const SizedBox(height: AppDimens.paddingSmall),
        _DetailMetaRow(
          title: context.l10n.subscriptionSubscribedOn,
          value: formatedDate(DateTime.parse(subscription.startDate)),
        ),
        const SizedBox(height: AppDimens.paddingExtraSmall),
        _DetailMetaRow(
          title: context.l10n.commonCreatedAt,
          value: formatedDate(DateTime.parse(subscription.createdAt!)),
        ),
        if (SubscriptionConst.isActive(normalizedStatus)) ...[
          const SizedBox(height: AppDimens.marginMedium),
          CustomButton(
            text: context.l10n.subscriptionUnsubscribe,
            loading: isUnsubscribing,
            onPressed: onUnsubscribePressed,
          ),
        ],
      ],
    );
  }
}

class _DetailMetaRow extends StatelessWidget {
  const _DetailMetaRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
