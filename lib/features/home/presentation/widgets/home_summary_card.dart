import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/home/presentation/widgets/home_wallet_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeSummaryCard extends StatelessWidget {
  const HomeSummaryCard({
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
    final l10n = context.l10n;
    final balanceStyle =
        (balance >= 0
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleLarge?.copyWith(color: Colors.red))
            ?.copyWith(fontWeight: FontWeight.bold);

    final openWallets = onOpenWallets;
    final balanceHeader = Column(
      crossAxisAlignment: openWallets == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(l10n.homeBalance, style: theme.textTheme.titleSmall),
        Text(
          NumberFormatUtils.formatCurrency(
            balance,
            currencyCode: referenceCurrencyCode,
          ),
          textAlign: openWallets == null ? TextAlign.center : TextAlign.start,
          style: balanceStyle,
        ),
      ],
    );
    final monthlyCards = [
      _monthlyCard(
        label: l10n.homeMonthlyInflow,
        amount: monthlyInflow,
        icon: IconLinks.income,
        color: incomeColor,
        onTap: onMonthlyInflowTap,
        compact: openWallets != null,
      ),
      _monthlyCard(
        label: l10n.homeMonthlyOutflow,
        amount: monthlyOutflow,
        icon: IconLinks.expense,
        color: expenseColor,
        onTap: onMonthlyOutflowTap,
        compact: openWallets != null,
      ),
    ];

    if (openWallets == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BicountReveal(
            delay: const Duration(milliseconds: 40),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingExtraLarge),
              child: balanceHeader,
            ),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          BicountReveal(
            delay: const Duration(milliseconds: 110),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: monthlyCards.first),
                    const SizedBox(width: AppDimens.marginMedium),
                    Expanded(child: monthlyCards.last),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.paddingExtraLarge,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppDimens.paddingMedium,
              0,
              HomeWalletPreview.width + AppDimens.paddingSmall,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                balanceHeader,
                const SizedBox(height: AppDimens.spacingMedium),
                monthlyCards.first,
                const SizedBox(height: AppDimens.spacingSmall),
                monthlyCards.last,
              ],
            ),
          ),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            width: HomeWalletPreview.width,
            child: HomeWalletPreview(onOpen: openWallets),
          ),
        ],
      ),
    );
  }

  Widget _monthlyCard({
    required String label,
    required double amount,
    required String icon,
    required Color color,
    required VoidCallback? onTap,
    required bool compact,
  }) => CardTypeRevenue(
    label: label,
    amount: amount,
    color: color,
    onTap: onTap ?? () {},
    compact: compact,
    icon: SvgPicture.asset(
      icon,
      width: AppDimens.iconSizeSmall,
      height: AppDimens.iconSizeSmall,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    ),
  );
}
