import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/home/presentation/widgets/home_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeSliverHeaderDelegate({
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
  double get minExtent => 84;

  @override
  double get maxExtent => 280;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collapseProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final isCollapsed = collapseProgress >= 0.58;
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: balance >= 0 ? null : Colors.red,
    );

    return ClipRRect(
      // borderRadius: BorderRadius.circular(AppDimens.borderRadiusUltraLarge),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppDimens.borderRadiusUltraLarge),
          ),
        ),
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isCollapsed
                ? _CollapsedHomeHeader(
                    key: const ValueKey('home-collapsed'),
                    balanceText: NumberFormatUtils.compactCurrency(
                      balance,
                      currencyCode: referenceCurrencyCode,
                      compactThreshold: 100000,
                    ),
                    amountStyle: amountStyle,
                  )
                : _ExpandedHomeHeader(
                    key: const ValueKey('home-expanded'),
                    balance: balance,
                    referenceCurrencyCode: referenceCurrencyCode,
                    monthlyInflow: monthlyInflow,
                    monthlyOutflow: monthlyOutflow,
                    incomeColor: incomeColor,
                    expenseColor: expenseColor,
                    onMonthlyInflowTap: onMonthlyInflowTap,
                    onMonthlyOutflowTap: onMonthlyOutflowTap,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeSliverHeaderDelegate oldDelegate) {
    return balance != oldDelegate.balance ||
        referenceCurrencyCode != oldDelegate.referenceCurrencyCode ||
        monthlyInflow != oldDelegate.monthlyInflow ||
        monthlyOutflow != oldDelegate.monthlyOutflow ||
        incomeColor != oldDelegate.incomeColor ||
        expenseColor != oldDelegate.expenseColor ||
        onMonthlyInflowTap != oldDelegate.onMonthlyInflowTap ||
        onMonthlyOutflowTap != oldDelegate.onMonthlyOutflowTap;
  }
}

class _ExpandedHomeHeader extends StatelessWidget {
  const _ExpandedHomeHeader({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth,
              child: HomeSummaryCard(
                balance: balance,
                referenceCurrencyCode: referenceCurrencyCode,
                monthlyInflow: monthlyInflow,
                monthlyOutflow: monthlyOutflow,
                incomeColor: incomeColor,
                expenseColor: expenseColor,
                onMonthlyInflowTap: onMonthlyInflowTap,
                onMonthlyOutflowTap: onMonthlyOutflowTap,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CollapsedHomeHeader extends StatelessWidget {
  const _CollapsedHomeHeader({
    super.key,
    required this.balanceText,
    required this.amountStyle,
  });

  final String balanceText;
  final TextStyle amountStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(left: AppDimens.marginMedium),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
            ),
            child: Center(
              child: SvgPicture.asset(
                IconLinks.wallet,
                width: AppDimens.iconSizeMedium,
                height: AppDimens.iconSizeMedium,
                colorFilter: ColorFilter.mode(
                  theme.textTheme.titleMedium!.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.marginMedium),
          Expanded(
            child: Text(
              context.l10n.homeBalance,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: AppDimens.marginSmall),
          Text(balanceText, style: amountStyle),
          const SizedBox(width: AppDimens.marginMedium),
        ],
      ),
    );
  }
}
