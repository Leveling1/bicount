import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/analysis/domain/services/analysis_wallet_distribution.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_wallet_distribution_ring.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AnalysisWalletDistributionCard extends StatelessWidget {
  const AnalysisWalletDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state.wallets.length < 2) return const SizedBox.shrink();

        final balances = state.balances;
        final l10n = context.l10n;
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.marginLarge),
          child: DetailsCard(
            isMargin: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppDimens.spacingSmall,
              children: [
                Text(
                  l10n.analysisWalletDistribution,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  l10n.analysisWalletCurrentBalances,
                  style: theme.textTheme.bodySmall,
                ),
                if (balances == null)
                  Text(
                    l10n.analysisWalletBalancesUnavailable,
                    style: theme.textTheme.bodySmall,
                  )
                else
                  _WalletDistributionContent(
                    distribution: AnalysisWalletDistribution.fromBalances(
                      state.wallets,
                      balances,
                      state.currencyConfig,
                    ),
                    walletIds: state.wallets
                        .map((wallet) => wallet.id)
                        .toList(),
                    currencyCode: state.currencyConfig.referenceCurrencyCode,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletDistributionContent extends StatelessWidget {
  const _WalletDistributionContent({
    required this.distribution,
    required this.walletIds,
    required this.currencyCode,
  });

  final AnalysisWalletDistribution distribution;
  final List<String> walletIds;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.extension<OtherTheme>()!;
    final palette = [
      colors.analysisRevenue!,
      colors.analysisSalary!,
      colors.analysisDebt!,
      colors.analysisSubscription!,
      colors.analysisRepayment!,
      colors.analysisExpense!,
      colors.analysisOther!,
    ];
    final colorByWallet = {
      for (final (index, id) in walletIds.indexed)
        id: palette[index % palette.length],
    };
    final locale = Localizations.localeOf(context).toString();
    final percent = NumberFormat.percentPattern(locale)
      ..maximumFractionDigits = 1;
    String amountLabel(double amount) => NumberFormatUtils.formatCurrency(
      amount,
      locale: locale,
      currencyCode: currencyCode,
    );
    final total = distribution.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingSmall,
      children: [
        if (distribution.positive.isEmpty)
          Text(
            l10n.analysisWalletNoPositiveBalances,
            style: theme.textTheme.bodySmall,
          )
        else ...[
          AnalysisWalletDistributionRing(
            totalLabel: amountLabel(total),
            slices: [
              for (final entry in distribution.positive)
                (amount: entry.amount!, color: colorByWallet[entry.wallet.id]!),
            ],
          ),
          for (final entry in distribution.positive)
            _WalletBalanceRow(
              name: walletLabel(context, entry.wallet),
              amount: amountLabel(entry.amount!),
              share: percent.format(entry.amount! / total),
              color: colorByWallet[entry.wallet.id],
            ),
        ],
        if (distribution.excluded.isNotEmpty) ...[
          const Divider(),
          Text(
            l10n.analysisWalletOutsideChart,
            style: theme.textTheme.bodySmall,
          ),
          for (final entry in distribution.excluded)
            _WalletBalanceRow(
              name: walletLabel(context, entry.wallet),
              amount: entry.amount == null
                  ? l10n.analysisWalletBalanceUnavailable
                  : amountLabel(entry.amount!),
            ),
        ],
      ],
    );
  }
}

class _WalletBalanceRow extends StatelessWidget {
  const _WalletBalanceRow({
    required this.name,
    required this.amount,
    this.share,
    this.color,
  });

  final String name;
  final String amount;
  final String? share;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = share;
    return Row(
      spacing: AppDimens.spacingSmall,
      children: [
        if (color != null)
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: AppSizes.dp10),
          ),
        Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
        Expanded(
          flex: percentage == null ? 1 : 2,
          child: FittedBox(
            alignment: AlignmentDirectional.centerEnd,
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                text: amount,
                children: [
                  if (percentage != null)
                    TextSpan(
                      text: ' | $percentage',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              maxLines: 1,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }
}
