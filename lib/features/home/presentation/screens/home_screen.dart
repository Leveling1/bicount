import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/home/presentation/widgets/home_recent_activity_section.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/home_recurring_fundings_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/services/notification_helper.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onCardTap, required this.data});

  final CardTapCallback? onCardTap;
  final MainEntity data;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
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
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          height: height - AppDimens.bottomBarHeight,
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
                            currencyCode: data.referenceCurrencyCode,
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
                            amount: data.monthlySubscriptionSpend,
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
              if (data.recurringFundings.isNotEmpty)
                BicountReveal(
                  delay: const Duration(milliseconds: 150),
                  child: HomeRecurringFundingsStatusCard(
                    data: data,
                    onTap: () => context.push('/recurring-fundings'),
                  ),
                ),
              Expanded(
                child: HomeRecentActivitySection(
                  data: data,
                  onShowMore: () => onCardTap?.call(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
