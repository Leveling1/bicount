import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_flight.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:flutter/material.dart';

class WalletOverviewCard extends StatelessWidget {
  const WalletOverviewCard({
    super.key,
    required this.wallet,
    required this.balances,
    required this.onHistory,
    required this.onEdit,
  });

  final WalletModel wallet;
  final List<WalletBalance> balances;
  final VoidCallback onHistory;
  final VoidCallback? onEdit;

  static const double aspectRatio = 1.84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final flight = WalletCardFlight.maybeOf(context);
    final moving = flight?.movingIds.contains(wallet.id) ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: SizedBox.expand(
                  key: flight?.geometry.anchor(
                    WalletCardEndpoint.list,
                    wallet.id,
                  ),
                  child: moving
                      ? null
                      : WalletCardFace(
                          wallet: wallet,
                          showDetails: true,
                          onTap: onHistory,
                        ),
                ),
              ),
            ),
            if (!moving)
              PositionedDirectional(
                start: 8,
                bottom: 0,
                child: WalletOverviewActions(
                  wallet: wallet,
                  onHistory: onHistory,
                  onEdit: onEdit,
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, top: 4),
          child: Visibility(
            visible: !moving,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (wallet.archivedAt != null)
                  Text(l10n.walletArchived, style: theme.textTheme.labelMedium),
                if (balances.isEmpty)
                  Text(
                    l10n.walletNoMovements,
                    style: theme.textTheme.labelMedium,
                  ),
                for (final balance in balances)
                  Text(
                    NumberFormatUtils.formatCurrency(
                      balance.minor / walletAmountScale,
                      currencyCode: balance.currency,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WalletOverviewActions extends StatelessWidget {
  const WalletOverviewActions({
    super.key,
    required this.wallet,
    this.onHistory,
    this.onEdit,
    this.decorative = false,
  });

  final WalletModel wallet;
  final VoidCallback? onHistory;
  final VoidCallback? onEdit;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = walletMetal(wallet);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WalletCardAction(
          tint: tint,
          label: l10n.navTransaction,
          icon: Icons.history,
          onPressed: onHistory,
          decorative: decorative,
        ),
        const SizedBox(width: 4),
        _WalletCardAction(
          tint: tint,
          label: l10n.walletEdit,
          icon: Icons.edit_outlined,
          onPressed: onEdit,
          decorative: decorative,
        ),
      ],
    );
  }
}

class _WalletCardAction extends StatelessWidget {
  const _WalletCardAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.tint,
    required this.decorative,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color tint;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = Color.alphaBlend(
      tint.withValues(alpha: .24),
      colors.surfaceContainerHighest,
    );
    return IconButton(
      tooltip: decorative ? null : label,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: colors.onSurface,
        minimumSize: const Size(34, 34),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: 16),
      onPressed: decorative ? () {} : onPressed,
    );
  }
}
