import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/friend/domain/services/friend_view_service.dart';
import 'package:bicount/features/friend/presentation/screens/detail_friend.dart';
import 'package:bicount/features/friend/presentation/screens/friends_directory_screen.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_card.dart';
import 'package:bicount/features/home/domain/services/home_monthly_flow_service.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/details_card.dart';
import '../widgets/profile_amount_cards_row.dart';
import '../widgets/profile_sliver_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.data});

  final MainEntity data;
  static const _friendViewService = FriendViewService();
  static const _monthlyFlowService = HomeMonthlyFlowService();

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;
    final monthlyFlow = _monthlyFlowService.build(
      data: data,
      currencyConfig: currencyConfig,
    );
    final visibleFriends = _friendViewService.visibleFriends(
      data.friends,
      currentUserUid: data.user.uid,
    );
    final theme = Theme.of(context);
    final incomeColor = theme.extension<OtherTheme>()!.income!;
    final expenseColor = theme.extension<OtherTheme>()!.expense!;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            //vertical: AppDimens.paddingSmall,
          ),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: ProfileSliverHeaderDelegate(
              image: data.user.image,
              name: data.user.username,
              email: data.user.email,
              balance: data.user.balance ?? 0,
              totalLabel: context.l10n.friendsTotal,
              onTap: () => context.push('/settings'),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          sliver: SliverToBoxAdapter(
            child: BicountReveal(
              delay: const Duration(milliseconds: 80),
              child: ProfileAmountCardsRow(
                leftTitle: context.l10n.profileIncome,
                leftIcon: IconLinks.income,
                leftValue: data.user.incomes ?? 0,
                leftColor: incomeColor,
                rightTitle: context.l10n.profileExpense,
                rightIcon: IconLinks.expense,
                rightValue: data.user.expenses ?? 0,
                rightColor: expenseColor,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          sliver: SliverToBoxAdapter(
            child: BicountReveal(
              delay: const Duration(milliseconds: 120),
              child: ProfileAmountCardsRow(
                leftTitle: context.l10n.homeMonthlyInflow,
                leftIcon: IconLinks.income,
                leftValue: monthlyFlow.inflowWithCarryover,
                leftColor: incomeColor,
                rightTitle: context.l10n.homeMonthlyOutflow,
                rightIcon: IconLinks.expense,
                rightValue: monthlyFlow.currentMonthOutflow,
                rightColor: expenseColor,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingMedium,
            AppDimens.marginMedium,
            AppDimens.paddingMedium,
            AppDimens.paddingExtraSmall,
          ),
          sliver: SliverToBoxAdapter(
            child: BicountReveal(
              delay: const Duration(milliseconds: 160),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.profileFriends,
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FriendsDirectoryScreen(),
                        ),
                      );
                    },
                    style: theme.textButtonTheme.style,
                    child: Text(
                      context.l10n.profileSeeAll,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (visibleFriends.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            sliver: SliverToBoxAdapter(
              child: BicountReveal(
                delay: const Duration(milliseconds: 200),
                child: DetailsCard(
                  child: Text(
                    context.l10n.profileFirstFriendHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final friend = visibleFriends[index];
                final card = FriendCard(
                  friend: friend,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailFriend(friend: friend),
                      ),
                    );
                  },
                );

                if (index >= 6) {
                  return card;
                }

                return BicountReveal(
                  delay: Duration(milliseconds: 200 + (index * 35)),
                  child: card,
                );
              }, childCount: visibleFriends.length),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimens.paddingLarge),
        ),
      ],
    );
  }
}
