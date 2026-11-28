import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/home/presentation/widgets/home_summary_card.dart';
import 'package:bicount/features/home/presentation/widgets/home_header_sliver_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

part 'home_collapsed_header.dart';

class HomeSliverHeader extends StatelessWidget {
  const HomeSliverHeader({
    super.key,
    required this.balance,
    required this.referenceCurrencyCode,
    this.onOpenWallets,
    required this.monthlyInflow,
    required this.monthlyOutflow,
    required this.incomeColor,
    required this.expenseColor,
    this.onMonthlyInflowTap,
    this.onMonthlyOutflowTap,
  });

  final double balance;
  final String referenceCurrencyCode;
  final VoidCallback? onOpenWallets;
  final double monthlyInflow;
  final double monthlyOutflow;
  final Color incomeColor;
  final Color expenseColor;
  final VoidCallback? onMonthlyInflowTap;
  final VoidCallback? onMonthlyOutflowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: balance >= 0 ? null : Colors.red,
    );

    return HomeHeaderSliverLayout(
      backgroundColor: theme.scaffoldBackgroundColor,
      expanded: HomeSummaryCard(
        key: const ValueKey('home-expanded'),
        balance: balance,
        referenceCurrencyCode: referenceCurrencyCode,
        onOpenWallets: onOpenWallets,
        monthlyInflow: monthlyInflow,
        monthlyOutflow: monthlyOutflow,
        incomeColor: incomeColor,
        expenseColor: expenseColor,
        onMonthlyInflowTap: onMonthlyInflowTap,
        onMonthlyOutflowTap: onMonthlyOutflowTap,
      ),
      collapsed: Padding(
        key: const ValueKey('home-collapsed'),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.dp22),
        child: _CollapsedHomeHeader(
          balanceText: NumberFormatUtils.compactCurrency(
            balance,
            currencyCode: referenceCurrencyCode,
            compactThreshold: 100000,
          ),
          amountStyle: amountStyle,
        ),
      ),
    );
  }
}
