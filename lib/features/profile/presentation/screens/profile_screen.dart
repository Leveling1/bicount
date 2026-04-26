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
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/details_card.dart';
import '../widgets/profile_card.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Column(
        children: [
          BicountReveal(
            delay: const Duration(milliseconds: 40),
            child: ProfileCard(
              image: data.user.image,
              name: data.user.username,
              email: data.user.email,
              balance: data.user.balance,
              onTap: () => context.push('/settings'),
            ),
          ),
          BicountReveal(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Flexible(
                  child: InfoCardAmount(
                    icon: IconLinks.income,
                    title: context.l10n.profileIncome,
                    value: data.user.incomes!,
                    color: Theme.of(context).extension<OtherTheme>()!.income!,
                  ),
                ),
                const SizedBox(width: AppDimens.marginMedium),
                Flexible(
                  child: InfoCardAmount(
                    icon: IconLinks.expense,
                    title: context.l10n.profileExpense,
                    value: data.user.expenses!,
                    color: Theme.of(context).extension<OtherTheme>()!.expense!,
                  ),
                ),
              ],
            ),
          ),
          BicountReveal(
            delay: const Duration(milliseconds: 150),
            child: Row(
              children: [
                Flexible(
                  child: InfoCardAmount(
                    icon: IconLinks.income,
                    title: context.l10n.homeMonthlyInflow,
                    value: monthlyFlow.inflowWithCarryover,
                    color: Theme.of(context).extension<OtherTheme>()!.income!,
                  ),
                ),
                const SizedBox(width: AppDimens.marginMedium),
                Flexible(
                  child: InfoCardAmount(
                    icon: IconLinks.expense,
                    title: context.l10n.homeMonthlyOutflow,
                    value: monthlyFlow.currentMonthOutflow,
                    color: Theme.of(context).extension<OtherTheme>()!.expense!,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.marginMedium),
          BicountReveal(
            delay: const Duration(milliseconds: 190),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.profileFriends,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FriendsDirectoryScreen(),
                      ),
                    );
                  },
                  style: Theme.of(context).textButtonTheme.style,
                  child: Text(
                    context.l10n.profileSeeAll,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          if (visibleFriends.isEmpty)
            BicountReveal(
              delay: const Duration(milliseconds: 240),
              child: DetailsCard(
                child: Text(
                  context.l10n.profileFirstFriendHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: visibleFriends.take(3).toList().asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final friend = entry.value;
                      return BicountReveal(
                        delay: Duration(milliseconds: 240 + (index * 45)),
                        child: FriendCard(
                          friend: friend,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailFriend(friend: friend),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
