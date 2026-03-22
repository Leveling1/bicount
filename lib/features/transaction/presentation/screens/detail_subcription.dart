import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/get_new_date.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailSubscription extends StatelessWidget {
  const DetailSubscription({
    super.key,
    required this.friend,
    required this.subscription,
  });

  final FriendsModel friend;
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    final badgeColor = SubscriptionConst.getStatusColor(
      subscription.status!,
      context,
    );
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is UnsubscriptionSuccess) {
          NotificationHelper.showSuccessNotification(
            context,
            context.l10n.subscriptionUnsubscribeSuccess,
          );
        } else if (state is UnsubscriptionError) {
          NotificationHelper.showFailureNotification(
            context,
            localizeRuntimeMessage(context, state.failure.message),
          );
        }
      },
      builder: (context, state) {
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
            const SizedBox(height: AppDimens.paddingSmallMedium),
            Text(
              friend.username,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.paddingExtraSmall),
            Container(
              constraints: const BoxConstraints(minWidth: 70),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                context.subscriptionStatusLabel(subscription.status!),
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
                    title: subscription.status == SubscriptionConst.active
                        ? context.l10n.subscriptionNextBilling
                        : context.l10n.subscriptionBillingStop,
                    content: subscription.status == SubscriptionConst.active
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
              color: Theme.of(
                context,
              ).extension<OtherTheme>()!.personnalIncome!,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.subscriptionSubscribedOn,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  formatedDate(DateTime.parse(subscription.startDate)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingExtraSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.commonCreatedAt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  formatedDate(DateTime.parse(subscription.createdAt!)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (subscription.status == SubscriptionConst.active)
              Column(
                children: [
                  const SizedBox(height: AppDimens.marginMedium),
                  CustomButton(
                    text: context.l10n.subscriptionUnsubscribe,
                    loading: state is UnsubscriptionLoading,
                    onPressed: () {
                      context.read<TransactionBloc>().add(
                        UnsubscribeEvent(subscription),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: AppDimens.marginLarge),
          ],
        );
      },
    );
  }
}
