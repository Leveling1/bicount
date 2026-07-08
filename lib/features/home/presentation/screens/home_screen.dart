import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/home/domain/services/home_monthly_flow_service.dart';
import 'package:bicount/core/widgets/quick_action_button.dart';
import 'package:bicount/features/home/presentation/widgets/home_recent_activity_section.dart';
import 'package:bicount/features/home/presentation/widgets/home_sliver_header.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/home_recurring_fundings_status_card.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_helper.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onCardTap,
    required this.data,
  });

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
        final showRecurringStatusCard = const SalaryDashboardBuilder()
            .build(
              recurringTransferts: data.recurringTransferts,
              transactions: data.transactions,
              currencyConfig: currencyConfig,
            )
            .hasPlans;
        final theme = Theme.of(context);
        final incomeColor = theme.extension<OtherTheme>()!.income!;
        final expenseColor = theme.extension<OtherTheme>()!.expense!;

        return SizedBox(
          height: height - AppDimens.bottomBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HomeSliverHeaderDelegate(
                    balance: data.user.balance ?? 0.0,
                    referenceCurrencyCode: data.referenceCurrencyCode,
                    monthlyInflow: monthlyFlow.inflowWithCarryover,
                    monthlyOutflow: monthlyFlow.currentMonthOutflow,
                    incomeColor: incomeColor,
                    expenseColor: expenseColor,
                    onMonthlyInflowTap: () => onCardTap?.call(2),
                    onMonthlyOutflowTap: () => onCardTap?.call(1),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimens.spacingMedium),
                ),
                if (showRecurringStatusCard)
                  SliverToBoxAdapter(
                    child: BicountReveal(
                      delay: const Duration(milliseconds: 150),
                      child: HomeRecurringFundingsStatusCard(
                        data: data,
                        onTap: () => context.push('/recurring-fundings'),
                      ),
                    ),
                  ),
                if (showRecurringStatusCard) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimens.spacingMedium),
                  ),
                ],
                if (data.transactions.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: BicountReveal(
                      delay: const Duration(milliseconds: 180),
                      child: TransactionButton(data: data),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimens.spacingMedium),
                ),
                SliverToBoxAdapter(
                  child: HomeRecentActivitySection(
                    data: data,
                    onShowMore: () => onCardTap?.call(2),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimens.paddingExtraLarge),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
