import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/home/domain/services/home_monthly_flow_service.dart';
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

  static const _monthlyFlowService = HomeMonthlyFlowService();
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
        final currencyConfig = context.watch<CurrencyCubit>().state.config;
        final monthlyFlow = _monthlyFlowService.build(
          data: data,
          currencyConfig: currencyConfig,
        );
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            onTap: () => onCardTap?.call(2),
                            label: context.l10n.homeMonthlyInflow,
                            amount: monthlyFlow.inflowWithCarryover,
                            icon: SvgPicture.asset(
                              IconLinks.income,
                              width: AppDimens.iconSizeSmall,
                              height: AppDimens.iconSizeSmall,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            color: Theme.of(
                              context,
                            ).extension<OtherTheme>()!.income!,
                          ),
                        ),
                        const SizedBox(width: AppDimens.marginMedium),
                        Expanded(
                          child: CardTypeRevenue(
                            onTap: () => onCardTap?.call(1),
                            label: context.l10n.homeMonthlyOutflow,
                            amount: monthlyFlow.currentMonthOutflow,
                            icon: SvgPicture.asset(
                              IconLinks.expense,
                              width: AppDimens.iconSizeSmall,
                              height: AppDimens.iconSizeSmall,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            color: Theme.of(
                              context,
                            ).extension<OtherTheme>()!.expense!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (data.recurringTransferts.isNotEmpty)
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
