import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../transaction/domain/entities/transaction_detail_args.dart';
import '../../../transaction/presentation/screens/detail_transaction_screen.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onCardTap, required this.data});

  final CardTapCallback? onCardTap;
  final MainEntity data;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final recurringSpend = data.subscriptions.fold<double>(
      0,
      (sum, subscription) => sum + subscription.amount,
    );
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          NotificationHelper.showFailureNotification(
            context,
            localizeRuntimeMessage(context, state.message),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            height: height - AppDimens.bottomBarHeight.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppDimens.spacingMedium,
              children: [
                BicountReveal(
                  delay: const Duration(milliseconds: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.paddingExtraLarge,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            context.l10n.homeBalance,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            NumberFormatUtils.formatCurrency(
                              data.user.balance ?? 0.0,
                            ),
                            style: (data.user.balance ?? 0.0) >= 0
                                ? Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold)
                                : Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BicountReveal(
                  delay: const Duration(milliseconds: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.homeAccounts,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimens.marginMedium),
                      Row(
                        children: [
                          Expanded(
                            child: CardTypeRevenue(
                              onTap: () => onCardTap?.call(3),
                              label: context.l10n.profilePersonal,
                              amount: data.user.personalIncome ?? 0.0,
                              icon: SvgPicture.asset(
                                IconLinks.user,
                                width: AppDimens.iconSizeSmall,
                                height: AppDimens.iconSizeSmall,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              color: Theme.of(
                                context,
                              ).extension<OtherTheme>()!.personnalIncome!,
                            ),
                          ),
                          const SizedBox(width: AppDimens.marginMedium),
                          Expanded(
                            child: CardTypeRevenue(
                              onTap: () => onCardTap?.call(1),
                              label: context.l10n.profileRecurring,
                              amount: recurringSpend,
                              icon: SvgPicture.asset(
                                IconLinks.graph,
                                width: AppDimens.iconSizeSmall,
                                height: AppDimens.iconSizeSmall,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (data.transactions.isNotEmpty)
                  BicountReveal(
                    delay: const Duration(milliseconds: 180),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.homeTransactions,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () => onCardTap?.call(2),
                          style: Theme.of(context).textButtonTheme.style,
                          child: Text(
                            context.l10n.homeShowMore,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 30.h),
                    itemCount: data.transactions.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      final entity = TransactionEntity.fromTransaction(
                        data.transactions[index],
                      );

                      return BicountReveal(
                        delay: Duration(milliseconds: 210 + (index * 45)),
                        child: TransactionCard(
                          transaction: entity,
                          onTap: () {
                            showCustomBottomSheet(
                              context: context,
                              minHeight: 0.95,
                              color: null,
                              child: DetailTransactionScreen(
                                key: ValueKey(entity.tid),
                                transaction: TransactionDetailArgs(
                                  user: data.user,
                                  transactionDetail: entity,
                                  friends: data.friends,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
