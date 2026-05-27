import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeSummaryCard extends StatelessWidget {
  const HomeSummaryCard({
    super.key,
    required this.balance,
    required this.referenceCurrencyCode,
    required this.monthlyInflow,
    required this.monthlyOutflow,
    required this.incomeColor,
    required this.expenseColor,
    this.onMonthlyInflowTap,
    this.onMonthlyOutflowTap,
  });

  final double balance;
  final String referenceCurrencyCode;
  final double monthlyInflow;
  final double monthlyOutflow;
  final Color incomeColor;
  final Color expenseColor;
  final VoidCallback? onMonthlyInflowTap;
  final VoidCallback? onMonthlyOutflowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final balanceStyle =
        (balance >= 0
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleLarge?.copyWith(color: Colors.red))
            ?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
                  Text(l10n.homeBalance, style: theme.textTheme.titleSmall),
                  Text(
                    NumberFormatUtils.formatCurrency(
                      balance,
                      currencyCode: referenceCurrencyCode,
                    ),
                    textAlign: TextAlign.center,
                    style: balanceStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingMedium),
        BicountReveal(
          delay: const Duration(milliseconds: 110),
          child: Row(
            children: [
              Expanded(
                child: CardTypeRevenue(
                  onTap: onMonthlyInflowTap ?? () {},
                  label: l10n.homeMonthlyInflow,
                  amount: monthlyInflow,
                  icon: SvgPicture.asset(
                    IconLinks.income,
                    width: AppDimens.iconSizeSmall,
                    height: AppDimens.iconSizeSmall,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  color: incomeColor,
                ),
              ),
              const SizedBox(width: AppDimens.marginMedium),
              Expanded(
                child: CardTypeRevenue(
                  onTap: onMonthlyOutflowTap ?? () {},
                  label: l10n.homeMonthlyOutflow,
                  amount: monthlyOutflow,
                  icon: SvgPicture.asset(
                    IconLinks.expense,
                    width: AppDimens.iconSizeSmall,
                    height: AppDimens.iconSizeSmall,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  color: expenseColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
